
import Foundation

class UploadPendingChangeOperation<Task: UploadChangesTask, DependencyProvider: SynchronizationDependencyProvider>: SynchronizationOperation, UploadChangesTaskContext where Task.Change == DependencyProvider.Changeset.Change {

    let task: Task
    let changeStore: DependencyProvider.ChangeStore
    let resolver: DependencyProvider.ConflictResolver
    let persistentStore: DependencyProvider.PersistentStore

    private let internalQueue = DispatchQueue(label: "upload_pending_changes_queue")

    private var _pendingChanges: [Task.Change] = []
    private var _processingChanges: [Task.Change] = []

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

    func pendingChanges() -> [Task.Change] {
        return _pendingChanges
    }

    func didStartUploading(_ batch: [Task.Change]) {
        internalQueue.async { [weak self] in
            self?._processingChanges = batch
            self?.changeStore.purge(batch)
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

    private func resolveFailedChangeUpload(changes: [Task.Change]) {
        changeStore.purge(changes)
        let conflict = FailedPendingChangesUploadConflit<Change>(
            failedChanges: changes,
            pendingChanges: changeStore.storedChanges()
        )
        let solution = resolver.resolve(conflict)
        changeStore.store(solution.changesToRestore)
    }
}
