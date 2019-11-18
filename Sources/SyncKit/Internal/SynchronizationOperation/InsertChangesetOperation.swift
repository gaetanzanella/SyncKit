
import Foundation

class InsertChangesetOperation<Task: ScheduleLocalChangesetTask, DependencyProvider: SynchronizationDependencyProvider>: SynchronizationOperation, ScheduleLocalChangesetTaskContext where Task.Changeset == DependencyProvider.Changeset {

    private let task: Task
    private let changeStore: DependencyProvider.ChangeStore
    private let persistentStore: DependencyProvider.PersistentStore

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

    func didInsert(_ changeset: Task.Changeset) {
        internalQueue.async {
            do {
                try self.persistentStore.perform(changeset)
            } catch {
                self.endTask(with: error)
            }
        }
    }
}
