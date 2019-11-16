
import Foundation

class InsertChangesetOperation: SynchronizationOperation, ScheduleChangesetTaskContext {

    private let task: ScheduleChangesetTask
    private let changeStore: ScheduledChangeStore
    private let persistentStore: PersistentStore

    private let internalQueue = DispatchQueue(label: "insert_changes_queue")

    init(task: ScheduleChangesetTask,
         changeStore: ScheduledChangeStore,
         persistentStore: PersistentStore) {
        self.task = task
        self.changeStore = changeStore
        self.persistentStore = persistentStore
        super.init(label: .insertion)
    }

    // MARK: - SynchronizationOperation

    override func execute() {
        internalQueue.sync {
            task.execute(using: self)
        }
    }

    // MARK: - InsertChangesetTaskContext

    func insert(_ changeset: RecordChangeset) {
        internalQueue.async {
            do {
                try self.persistentStore.perform(changeset)
            } catch {
                self.finish(with: error)
            }
        }
    }
}
