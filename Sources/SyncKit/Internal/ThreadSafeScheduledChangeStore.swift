
import Foundation

class ThreadSafeScheduledChangeStore<Store: ScheduledChangeStore>: ScheduledChangeStore {

    let store: Store

    var changeUpdateHandler: ((Int) -> Void)?

    private let accessQueue = DispatchQueue(label: "scheduled_change_queue")

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
        accessQueue.sync {
            store.purge(changes)
        }
        notifyCountChange()
    }

    func purge(_ changes: [ScheduledChange<Store.ID>]) {
        accessQueue.sync {
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
