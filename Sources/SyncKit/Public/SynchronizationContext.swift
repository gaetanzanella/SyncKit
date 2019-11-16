
import Foundation

public class SynchronizationContext {

    // MARK: - Private properties

    private let persistentStore: PersistentStore
    private let scheduledChangeStore: ScheduledChangeStore
    private let conflictResolver: ScheduledChangeConflictResolver

    private var monitors: [SynchronizationMonitor] = []

    private lazy var insertionQueue = makeOperationQueue()
    private lazy var operationQueue = makeOperationQueue()

    // MARK: - Life Cycle

    public init(persistentStore: PersistentStore,
                scheduledChangeStore: ScheduledChangeStore,
                conflictResolver: ScheduledChangeConflictResolver) {
        let threadSafeChangeStore = ThreadSafeScheduledChangeStore(store: scheduledChangeStore)
        self.persistentStore = persistentStore
        self.scheduledChangeStore = threadSafeChangeStore
        self.conflictResolver = conflictResolver
        threadSafeChangeStore.changeUpdateHandler = { [ weak self] count in
            self?.notifyMonitors { $0.notifyPendingChangesCountUpdate(count) }
        }
    }

    // MARK: - Public methods

    public func perform(_ task: DownloadRemoteChangesTask,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        let operation = FetchRemoteChangesOperation(
            task: task,
            changeStore: scheduledChangeStore,
            conflictResolver: conflictResolver,
            persistentStore: persistentStore
        )
        schedule(operation, completion: completion)
    }

    public func perform(_ task: UploadPendingChangesTask,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        let operation = UploadPendingChangeOperation(
            task: task,
            resolver: conflictResolver,
            changeStore: scheduledChangeStore,
            persistentStore: persistentStore
        )
        schedule(operation, completion: completion)
    }

    public func perform(_ task: ScheduleChangesetTask,
                         completion: @escaping (Result<Void, Error>) -> Void) {
        let operation = InsertChangesetOperation(
            task: task,
            changeStore: scheduledChangeStore,
            persistentStore: persistentStore
        )
        schedule(operation, completion: completion)
    }

    public func add(_ monitor: SynchronizationMonitor) {
        monitors.append(monitor)
    }

    // MARK: - Private

    private func schedule(_ operation: SynchronizationOperation,
                          completion: @escaping (Result<Void, Error>) -> Void) {
        let label = operation.label
        operation.startBlock = { [weak self] in
            switch label {
            case .download:
                self?.notify(.fetchingChanges)
            case .upload:
                self?.notify(.uploadingChanges)
            case .insertion:
                break
            }
        }
        operation.finishBlock = { [weak self] error in
            completion(error.flatMap { .failure($0) } ?? .success(()))
            guard let error = error else { return }
            switch label {
            case .download, .upload:
                self?.notify(.pending)
                self?.notify(error)
            case .insertion:
                self?.notify(error)
            }
        }
        switch label {
        case .download, .upload:
            operationQueue.addOperation(operation)
        case .insertion:
            insertionQueue.addOperation(operation)
        }
    }

    private func notify(_ error: Error) {
        notifyMonitors { $0.notify(error) }
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
