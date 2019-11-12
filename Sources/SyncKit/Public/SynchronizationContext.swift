
import Foundation

public class SynchronizationContext {

    // MARK: - Private properties

    private let persistentStore: PersistentStore
    private let remoteStore: RemoteStore
    private let scheduledChangeStore: ScheduledChangeStore
    private let conflictResolver: ScheduledChangeConflictResolver

    private var monitors: [SynchronizationMonitor] = []

    private let insertionQueue = DispatchQueue(label: "changeset_assertion_queue")
    private lazy var operationQueue = makeOperationQueue()

    // MARK: - Life Cycle

    public init(remoteStore: RemoteStore,
                persistentStore: PersistentStore,
                scheduledChangeStore: ScheduledChangeStore,
                conflictResolver: ScheduledChangeConflictResolver) {
        let threadSafeChangeStore = ThreadSafeScheduledChangeStore(store: scheduledChangeStore)
        self.remoteStore = remoteStore
        self.persistentStore = persistentStore
        self.scheduledChangeStore = threadSafeChangeStore
        self.conflictResolver = conflictResolver
        threadSafeChangeStore.changeUpdateHandler = { [ weak self] count in
            self?.notifyMonitors { $0.notifyPendingChangesCountUpdate(count) }
        }
    }

    // MARK: - Public methods

    public func downloadRemoteChanges(using strategy: DownloadRemoteChangesStrategy,
                                      completion: @escaping (Result<Void, Error>) -> Void) {
        let operation = FetchRemoteChangesOperation(
            strategy: strategy,
            changeStore: scheduledChangeStore,
            conflictResolver: conflictResolver,
            persistentStore: persistentStore,
            remoteStore: remoteStore,
            completion: { [weak self] result in
                self?.notifyIfErrorCompletion(result, completion)
            }
        )
        operation.startBlock = { [weak self] in
            self?.notify(.fetchingChanges)
        }
        operation.completionBlock = { [weak self] in
            self?.notify(.pending)
        }
        operationQueue.addOperation(operation)
    }

    public func uploadPendingChanges(using strategy: UploadPendingChangesStrategy,
                                     completion: @escaping (Result<Void, Error>) -> Void) {
        let operation = UploadPendingChangeOperation(
            strategy: strategy,
            resolver: conflictResolver,
            changeStore: scheduledChangeStore,
            persistentStore: persistentStore,
            remoteStore: remoteStore,
            completion: { [weak self] result in
                self?.notifyIfErrorCompletion(result, completion)
            }
        )
        operation.startBlock = { [weak self] in
            self?.notify(.uploadingChanges)
        }
        operation.completionBlock = { [weak self] in
            self?.notify(.pending)
        }
        operationQueue.addOperation(operation)
    }

    public func schedule(_ changeset: RecordChangeset,
                         completion: @escaping (Result<Void, Error>) -> Void) {
        insertionQueue.async { [weak self] in
            guard let self = self else { return }
            let conflict = InsertedChangeConflit(
                insertedChangeset: changeset,
                pendingChanges: self.scheduledChangeStore.storedChanges()
            )
            let solution = self.conflictResolver.resolve(conflict)
            let deletedChanges = changeset.recordsToSave.map {
                ScheduledChange(recordID: $0.id, operation: .delete)
            }
            let createdChanges = changeset.recordsToSave.map {
                ScheduledChange(recordID: $0.id, operation: .createOrModify)
            }
            self.scheduledChangeStore.purge(solution.pendingChangesToCancel)
            self.scheduledChangeStore.store(deletedChanges + createdChanges)
        }
        persistentStore.perform(changeset, completion: completion)
    }

    public func add(_ monitor: SynchronizationMonitor) {
        monitors.append(monitor)
    }

    // MARK: - Private

    private func handleChangesetDownload(changeset: RecordChangeset) {
        let conflit = FetchedChangeConflit(
            newChangeset: changeset,
            pendingChanges: scheduledChangeStore.storedChanges()
        )
        let solution = conflictResolver.resolve(conflit)
        scheduledChangeStore.purge(solution.pendingChangesToCancel)
        persistentStore.perform(solution.newChangesToPersist) { _ in }
    }

    private func notifyIfErrorCompletion(_ result: Result<Void, Error>,
                                         _ completion: @escaping (Result<Void, Error>) -> Void) {
        switch result {
        case let .failure(error):
            notifyMonitors { $0.notify(error) }
        case .success:
            break
        }
        completion(result)
    }

    private func notify(_ activity: SynchronizationContextActivity) {
        notifyMonitors { $0.notify(activity) }
    }

    private func notifyMonitors(handler: (SynchronizationMonitor) -> Void) {
        monitors.forEach(handler)
    }

    private func makeOperationQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }
}
