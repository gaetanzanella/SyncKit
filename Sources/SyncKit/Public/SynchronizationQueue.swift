
import Foundation

public class SynchronizationQueue<DependencyProvider: SynchronizationDependencyProvider> {

    // MARK: - Private properties

    private let dependencyProvider: DependencyProviderProxy<DependencyProvider>

    private var monitors: [SynchronizationMonitor] = []

    private lazy var insertionQueue = makeConcurrentQueue()
    private lazy var operationQueue = makeSerialQueue()

    // MARK: - Life Cycle

    public init(dependencyProvider: DependencyProvider) {
        self.dependencyProvider = DependencyProviderProxy(dependencyProvider)
        self.dependencyProvider.makeChangeStore().changeUpdateHandler = { [ weak self] count in
            self?.notifyMonitors { $0.notifyPendingChangesCountUpdate(count) }
        }
    }

    // MARK: - Public methods

    public func perform<Task: DownloadRemoteChangesTask>(_ task: Task,
                                                         completion: @escaping (Result<Void, Error>) -> Void) where Task.Record == DependencyProvider.Record {
        let operation = FetchRemoteChangesOperation(
            task: task,
            dependencyProvider: dependencyProvider
        )
        schedule(operation, completion: completion)
    }

    public func perform<Task: UploadPendingChangesTask>(_ task: Task,
                                                        completion: @escaping (Result<Void, Error>) -> Void) where Task.Record == DependencyProvider.Record {
        let operation = UploadPendingChangeOperation(
            task: task,
            dependencyProvider: dependencyProvider
        )
        schedule(operation, completion: completion)
    }

    public func perform<Task: ScheduleChangesetTask>(_ task: Task,
                                                     completion: @escaping (Result<Void, Error>) -> Void) where Task.Record == DependencyProvider.Record {
        let operation = InsertChangesetOperation(
            task: task,
            dependencyProvider: dependencyProvider
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

    private func makeConcurrentQueue() -> OperationQueue {
        let queue = OperationQueue()
        return queue
    }

    private func makeSerialQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }
}
