
import Foundation

enum ScheduledChangeStores {
    static let accessQueue = DispatchQueue(label: "change_store_queue", attributes: .concurrent)
}

class ThreadSafeScheduledChangeStore<Store: ScheduledChangeStore>: ScheduledChangeStore {

    let store: Store

    var changeUpdateHandler: ((Int) -> Void)?

    private var accessQueue: DispatchQueue {
        return ScheduledChangeStores.accessQueue
    }

    init(store: Store) {
        self.store = store
    }

    // MARK: - Private

    func storedChanges() -> [ScheduledChange<Store.ID>] {
        var changes: [ScheduledChange<Store.ID>] = []
        accessQueue.sync {
            changes = store.storedChanges()
        }
        return changes
    }

    func changesCount() -> Int {
        var count = 0
        accessQueue.sync {
            count = store.changesCount()
        }
        return count
    }

    func store(_ changes: [ScheduledChange<Store.ID>]) {
        accessQueue.sync(flags: .barrier) {
            store.store(changes)
        }
        notifyCountChange()
    }

    func purge(_ changes: [ScheduledChange<Store.ID>]) {
        accessQueue.sync(flags: .barrier) {
            self.store.purge(changes)
        }
        notifyCountChange()
    }

    // MARK: - Private

    private func notifyCountChange() {
        let count = changesCount()
        changeUpdateHandler?(count)
    }
}
