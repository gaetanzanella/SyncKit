
import Foundation

class FetchRemoteChangesOperation<Record,
    ChangeStore: ScheduledChangeStore,
    Resolver: ScheduledChangeConflictResolver,
    RecordStore: PersistentStore>: SynchronizationOperation, DownloadRemoteChangesContext
    where Record.ID == ChangeStore.ID, Resolver.Rec == Record, RecordStore.R == Record {

    let task: DownloadRemoteChangesTask
    let changeStore: ChangeStore
    let conflictResolver: Resolver
    let persistentStore: RecordStore

    private let internalQueue = DispatchQueue(label: "fetch_remote_changes_queue")

    init(task: DownloadRemoteChangesTask,
         changeStore: ChangeStore,
         conflictResolver: Resolver,
         persistentStore: RecordStore) {
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

    func didDownloadChangeset(_ changeset: RecordChangeset<Record>) {
        internalQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let conflict = FetchedChangeConflit(
                    newChangeset: changeset,
                    pendingChanges: ScheduledChangeBatch(self.changeStore.storedChanges())
                )
                let solution = self.conflictResolver.resolve(conflict)
                try self.persistentStore.perform(solution.newChangesToPersist)
                self.changeStore.purge(solution.pendingChangesToCancel.changes)
            } catch {
                self.finish(with: error)
            }
        }
    }
}
