
import Foundation

class InsertChangesetOperation<Task: ScheduleChangesetTask, DependencyProvider: SynchronizationDependencyProvider>: SynchronizationOperation, ScheduleChangesetTaskContext where Task.Record == DependencyProvider.Record {

    private let task: Task
    private let changeStore: DependencyProvider.ChangeStore
    private let persistentStore: DependencyProvider.Store

    private let internalQueue = DispatchQueue(label: "insert_changes_queue")

    init(task: Task,
         dependencyProvider: DependencyProvider) {
        self.task = task
        self.changeStore = dependencyProvider.makeChangeStore()
        self.persistentStore = dependencyProvider.makePersistentStore()
        super.init(label: .insertion)
    }

    // MARK: - SynchronizationOperation

    override func startTask() {
        internalQueue.sync {
            task.start(using: self)
        }
    }

    // MARK: - InsertChangesetTaskContext

    func didInsert(_ changeset: RecordChangeset<Task.Record>) {
        internalQueue.async {
            do {
                try self.persistentStore.perform(changeset)
            } catch {
                self.endTask(with: error)
            }
        }
    }
}
