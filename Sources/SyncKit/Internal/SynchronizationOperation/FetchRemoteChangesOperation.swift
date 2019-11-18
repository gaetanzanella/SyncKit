
import Foundation

class FetchRemoteChangesOperation<Task: DownloadLocalChangesetTask, DependencyProvider: SynchronizationDependencyProvider>: SynchronizationOperation, DownloadLocalChangesetContext where Task.Changeset == DependencyProvider.Changeset {

    let task: Task
    let resolver: DependencyProvider.ConflictResolver
    let changeStore: DependencyProvider.ChangeStore
    let persistentStore: DependencyProvider.PersistentStore

    private let internalQueue = DispatchQueue(label: "fetch_remote_changes_queue")

    init(task: Task,
         dependencyProvider: DependencyProvider) {
        self.task = task
        self.changeStore = dependencyProvider.makeChangeStore()
        self.persistentStore = dependencyProvider.makePersistentStore()
        self.resolver = dependencyProvider.makeConflictResolver()
        super.init(label: .download)
    }

    // MARK: - AsynchronousOperation

    override func startTask() {
        internalQueue.sync {
            let task = self.task
            task.start(using: self)
        }
    }

    // MARK: - DownloadRemoteChangesContext

    func didDownloadChangeset(_ changeset: Task.Changeset) {
        internalQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let conflict = FetchedLocalChangesetConflit(
                    newChangeset: changeset,
                    pendingChanges: self.changeStore.storedChanges()
                )
                let solution = self.resolver.resolve(conflict)
                try self.persistentStore.perform(solution.newChangesToPersist)
                self.changeStore.purge(solution.pendingChangesToCancel)
            } catch {
                self.endTask(with: error)
            }
        }
    }
}
