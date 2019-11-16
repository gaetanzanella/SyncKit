
import Foundation

class FetchRemoteChangesOperation: SynchronizationOperation, DownloadRemoteChangesContext {

    let task: DownloadRemoteChangesTask
    let changeStore: ScheduledChangeStore
    let conflictResolver: ScheduledChangeConflictResolver
    let persistentStore: PersistentStore

    private let internalQueue = DispatchQueue(label: "fetch_remote_changes_queue")

    init(task: DownloadRemoteChangesTask,
         changeStore: ScheduledChangeStore,
         conflictResolver: ScheduledChangeConflictResolver,
         persistentStore: PersistentStore) {
        self.task = task
        self.changeStore = changeStore
        self.conflictResolver = conflictResolver
        self.persistentStore = persistentStore
        super.init(label: .download)
    }

    // MARK: - AsynchronousOperation

    override func execute() {
        internalQueue.sync {
            let task = self.task
            task.execute(using: self)
        }
    }

    // MARK: - DownloadRemoteChangesContext

    func didDownloadChangeset(_ changeset: RecordChangeset) {
        internalQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let conflict = FetchedChangeConflit(
                    newChangeset: changeset,
                    pendingChanges: self.changeStore.storedChanges()
                )
                let solution = self.conflictResolver.resolve(conflict)
                try self.persistentStore.perform(solution.newChangesToPersist)
                self.changeStore.purge(solution.pendingChangesToCancel)
            } catch {
                self.finish(with: error)
            }
        }
    }
}
