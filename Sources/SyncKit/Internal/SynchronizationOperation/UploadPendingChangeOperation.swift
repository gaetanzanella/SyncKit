
import Foundation

class UploadPendingChangeOperation<Task: UploadPendingChangesTask, DependencyProvider: SynchronizationDependencyProvider>: SynchronizationOperation, UploadPendingChangesTaskContext where Task.Record == DependencyProvider.Record {

    let task: Task
    let changeStore: DependencyProvider.ChangeStore
    let resolver: DependencyProvider.ConflictResolver
    let persistentStore: DependencyProvider.Store

    private let internalQueue = DispatchQueue(label: "upload_pending_changes_queue")

    private var _pendingChanges: [ScheduledChange<Task.Record.ID>] = []
    private var _processingChanges: [ScheduledChange<Task.Record.ID>] = []

    // MARK: - Life Cycle

    init(task: Task,
         dependencyProvider: DependencyProvider) {
        self.task = task
        self.resolver = dependencyProvider.makeConflictResolver()
        self.changeStore = dependencyProvider.makeChangeStore()
        self.persistentStore = dependencyProvider.makePersistentStore()
        super.init(label: .download)
    }

    // MARK: - Operation

    override func startTask() {
        internalQueue.sync {
            _pendingChanges = changeStore.storedChanges()
            task.start(using: self)
        }
    }

    // MARK: - UploadPendingChangesContext

    func pendingChanges() -> ScheduledChangeBatch<Task.Record.ID> {
        return ScheduledChangeBatch(_pendingChanges)
    }

    func didStartUploading(_ batch: ScheduledChangeBatch<Task.Record.ID>) {
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

    private func resolveFailedChangeUpload(changes: [ScheduledChange<Task.Record.ID>]) {
        changeStore.purge(changes)
        let conflict = FailedChangeConflit<Task.Record>(
            failedChanges: ScheduledChangeBatch(changes),
            pendingChanges: ScheduledChangeBatch(changeStore.storedChanges())
        )
        let solution = resolver.resolve(conflict)
        changeStore.store(solution.changesToRestore)
    }
}
