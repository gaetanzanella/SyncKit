
import Foundation

class InsertChangesetOperation<
    Record,
    ChangeStore: ScheduledChangeStore,
    Store: PersistentStore>: SynchronizationOperation, ScheduleChangesetTaskContext
    where ChangeStore.ID == Record.ID, Store.Rec == Record {

    private let task: ScheduleChangesetTask
    private let changeStore: ChangeStore
    private let persistentStore: Store

    private let internalQueue = DispatchQueue(label: "insert_changes_queue")

    init(task: ScheduleChangesetTask,
         changeStore: ChangeStore,
         persistentStore: Store) {
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

    func insert(_ changeset: RecordChangeset<Record>) {
        internalQueue.async {
            do {
                try self.persistentStore.perform(changeset)
            } catch {
                self.finish(with: error)
            }
        }
    }
}
