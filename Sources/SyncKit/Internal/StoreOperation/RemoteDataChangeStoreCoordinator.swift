
import Foundation

private enum ScheduledChangeStores {
    static let accessQueue = DispatchQueue(label: "change_store_queue", attributes: .concurrent)
}

class ReadOnlyRemoteDataChangeStore<Store: RemoteDataChangeQueue> {

    fileprivate let store: Store

    fileprivate init(store: Store) {
        self.store = store
    }

    func pendingStoredChanges() -> [Store.RemoteChange] {
        store.changes(in: .pending)
    }

    func pendingChangesCount() -> Int {
        store.changesCount(in: .pending)
    }
}

class ReadAndWriteRemoteDataChangeStore<Store: RemoteDataChangeQueue>: ReadOnlyRemoteDataChangeStore<Store> {

    func moveProcessing(_ changes: [Store.RemoteChange]) {
        store.remove(changes, for: .pending)
        store.add(changes, for: .processing)
    }

    func addPending(_ changes: [Store.RemoteChange]) {
        store.add(changes, for: .pending)
    }

    func purgeProcessing(_ changes: [Store.RemoteChange]) {
        store.remove(changes, for: .processing)
    }

    func purgePending(_ changes: [Store.RemoteChange]) {
        store.remove(changes, for: .pending)
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
