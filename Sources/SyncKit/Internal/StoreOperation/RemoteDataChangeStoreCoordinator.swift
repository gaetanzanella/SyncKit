
import Foundation

private enum ScheduledChangeStores {
    static let accessQueue = DispatchQueue(label: "change_store_queue", attributes: .concurrent)
}

class ReadOnlyRemoteDataChangeStore<Store: RemoteDataChangeQueue> {

    fileprivate let store: Store

    fileprivate init(store: Store) {
        self.store = store
    }

    func storedChanges() -> [Store.RemoteChange] {
        store.changes()
    }

    func changesCount() -> Int {
        store.changesCount()
    }
}

class ReadAndWriteRemoteDataChangeStore<Store: RemoteDataChangeQueue>: ReadOnlyRemoteDataChangeStore<Store> {

    func store(_ changes: [Store.RemoteChange]) {
        store.add(changes)
    }

    func purge(_ changes: [Store.RemoteChange]) {
        store.remove(changes)
    }
}

class RemoteDataChangeStoreCoordinator<Store: RemoteDataChangeQueue> {

    private let store: Store

    private var accessQueue: DispatchQueue {
        return ScheduledChangeStores.accessQueue
    }

    init(store: Store) {
        self.store = store
    }

    // MARK: - Public

    func coordinateReading(block: (ReadOnlyRemoteDataChangeStore<Store>) throws -> Void) rethrows {
        let restrictedStore = ReadOnlyRemoteDataChangeStore(store: store)
        try accessQueue.sync {
            try block(restrictedStore)
        }
    }

    func coordinateWriting(block: (ReadAndWriteRemoteDataChangeStore<Store>) throws -> Void) rethrows {
        let restrictedStore = ReadAndWriteRemoteDataChangeStore(store: store)
        try accessQueue.sync(flags: .barrier) {
            try block(restrictedStore)
        }
    }
}
