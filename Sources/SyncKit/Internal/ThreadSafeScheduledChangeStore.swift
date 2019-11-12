
import Foundation

class ThreadSafeScheduledChangeStore: ScheduledChangeStore {

    let store: ScheduledChangeStore

    var changeUpdateHandler: ((Int) -> Void)?

    private let accessQueue = DispatchQueue(label: "scheduled_change_queue")

    init(store: ScheduledChangeStore) {
        self.store = store
    }

    // MARK: - Private

    func storedChanges() -> [ScheduledChange] {
        var changes: [ScheduledChange] = []
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

    func store(_ changes: [ScheduledChange]) {
        accessQueue.sync {
            store.purge(changes)
        }
        notifyCountChange()
    }

    func purge(_ changes: [ScheduledChange]) {
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
