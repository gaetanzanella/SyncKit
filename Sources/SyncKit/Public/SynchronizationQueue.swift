
import Foundation

public class SynchronizationQueue<DependencyProvider: SynchronizationDependencyProvider> {

    public typealias LocalChange = DependencyProvider.LocalChange
    public typealias RemoteChange = DependencyProvider.RemoteChange

    // MARK: - Private properties

    private let storeInterface: DataStoreInterface<DependencyProvider>

    private var monitors: [SynchronizationMonitor] = []

    private lazy var insertionQueue = makeConcurrentQueue()
    private lazy var operationQueue = makeSerialQueue()

    // MARK: - Life Cycle

    public init(dependencyProvider: DependencyProvider) {
        self.storeInterface = DataStoreInterface(dependancyProvider: dependencyProvider)
        self.storeInterface.changeUpdateHandler = { [ weak self] count in
            self?.notifyMonitors { $0.notifyPendingChangesCountUpdate(count) }
        }
    }

    // MARK: - Public methods

    public func perform<Task: DownloadLocalDataChangeTask>(_ task: Task,
                                                           completion: ((Result<Void, Error>) -> Void)? = nil) where Task.Change == LocalChange {
        let operation = DownloadLocalDataChangeOperation(
            task: task,
            storeInterface: storeInterface
        )
        schedule(operation, completion: completion)
    }

    public func perform<Task: UploadRemoteDataChangeTask>(_ task: Task,
                                                          completion: ((Result<Void, Error>) -> Void)? = nil) where Task.Change == RemoteChange {
        let operation = UploadRemoteDataChangeOperation(
            task: task,
            storeInterface: storeInterface
        )
        schedule(operation, completion: completion)
    }

    public func perform<Task: InsertLocalDataChangeTask>(_ task: Task,
                                                         completion: ((Result<Void, Error>) -> Void)? = nil) where Task.Change == LocalChange {
        let operation = InsertLocalDataChangeOperation(
            task: task,
            storeInterface: storeInterface
        )
        schedule(operation, completion: completion)
    }

    public func add(_ monitor: SynchronizationMonitor) {
        monitors.append(monitor)
    }

    // MARK: - Private

    private func schedule(_ operation: SynchronizationOperation,
                          completion: ((Result<Void, Error>) -> Void)? = nil) {
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
            completion?(error.flatMap { .failure($0) } ?? .success(()))
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
