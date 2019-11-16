
import Foundation

class UploadPendingChangeOperation: SynchronizationOperation, UploadPendingChangesTaskContext {

    let task: UploadPendingChangesTask
    let changeStore: ScheduledChangeStore
    let resolver: ScheduledChangeConflictResolver
    let persistentStore: PersistentStore

    private let internalQueue = DispatchQueue(label: "upload_pending_changes_queue")

    private var _pendingChanges: [ScheduledChange] = []
    private var _processingChanges: [ScheduledChange] = []

    // MARK: - Life Cycle

    init(task: UploadPendingChangesTask,
         resolver: ScheduledChangeConflictResolver,
         changeStore: ScheduledChangeStore,
         persistentStore: PersistentStore) {
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

    func pendingChanges() -> [ScheduledChange] {
        return _pendingChanges
    }

    func didStartUploading(_ changes: [ScheduledChange]) {
        internalQueue.async { [weak self] in
            self?._processingChanges = changes
            self?.changeStore.purge(changes)
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

    private func resolveFailedChangeUpload(changes: [ScheduledChange]) {
        changeStore.purge(changes)
        let conflict = FailedChangeConflit(
            failedChangeset: changes,
            pendingChanges: changeStore.storedChanges()
        )
        let solution = resolver.resolve(conflict)
        changeStore.store(solution.changesToRestore)
    }
}
