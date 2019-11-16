
import Foundation

class UploadPendingChangeOperation<Record,
    ChangeStore: ScheduledChangeStore,
    Resolver: ScheduledChangeConflictResolver,
    Store: PersistentStore>: SynchronizationOperation, UploadPendingChangesTaskContext
    where ChangeStore.ID == Record.ID, Resolver.Rec == Record, Store.R == Record {

    let task: UploadPendingChangesTask
    let changeStore: ChangeStore
    let resolver: Resolver
    let persistentStore: Store

    private let internalQueue = DispatchQueue(label: "upload_pending_changes_queue")

    private var _pendingChanges: [ScheduledChange<Record.ID>] = []
    private var _processingChanges: [ScheduledChange<Record.ID>] = []

    // MARK: - Life Cycle

    init(task: UploadPendingChangesTask,
         resolver: Resolver,
         changeStore: ChangeStore,
         persistentStore: Store) {
        self.task = task
        self.resolver = resolver
        self.changeStore = changeStore
        self.persistentStore = persistentStore
        super.init(label: .download)
    }

    // MARK: - Operation

    override func execute() {
        internalQueue.sync {
            _pendingChanges = changeStore.storedChanges()
            task.execute(using: self)
        }
    }

    // MARK: - UploadPendingChangesContext

    func pendingChanges() -> ScheduledChangeBatch<Record.ID> {
        return ScheduledChangeBatch(_pendingChanges)
    }

    func didStartUploading(_ batch: ScheduledChangeBatch<Record.ID>) {
        internalQueue.async { [weak self] in
            self?._processingChanges = batch.changes
            self?.changeStore.purge(batch.changes)
        }
    }

    func didFinishUploading() {
        internalQueue.async { [weak self] in
            self?._processingChanges = []
        }
    }

    func didFinishUploading(with error: Error) {
        internalQueue.async { [weak self] in
            guard let self = self else { return }
            let changes = self._processingChanges
            self._processingChanges = []
            self.resolveFailedChangeUpload(changes: changes)
        }
    }

    // MARK: - Private

    private func resolveFailedChangeUpload(changes: [ScheduledChange<Record.ID>]) {
        changeStore.purge(changes)
        let conflict = FailedChangeConflit<Record>(
            failedChanges: ScheduledChangeBatch(changes),
            pendingChanges: ScheduledChangeBatch(changeStore.storedChanges())
        )
        let solution = resolver.resolve(conflict)
        changeStore.store(solution.changesToRestore.changes)
    }
}
