
import Foundation

protocol UploadRemoteDataChangeStoreInterface {

    associatedtype RemoteChange: RemoteDataChange

    func pendingChanges() -> [RemoteChange]
    func purgeUploadedChanges(_ remoteChanges: [RemoteChange])
    func restoreFailedChanges(_ remoteChanges: [RemoteChange])
}

class UploadRemoteDataChangeOperation<Task: UploadRemoteDataChangeTask, StoreInterface: UploadRemoteDataChangeStoreInterface>: SynchronizationOperation where Task.Change == StoreInterface.RemoteChange {

    typealias RemoteChange = StoreInterface.RemoteChange

    let task: Task
    let storeInterface: StoreInterface

    private let internalQueue = DispatchQueue(label: "remote_data_change_uploading_queue")

    private var _pendingChanges: [RemoteChange] = []
    private var _processingChanges: [RemoteChange] = []

    // MARK: - Life Cycle

    init(task: Task,
         storeInterface: StoreInterface) {
        self.task = task
        self.storeInterface = storeInterface
        super.init(label: .download)
    }

    // MARK: - Operation

    override func startTask() {
        internalQueue.sync {
            _pendingChanges = storeInterface.pendingChanges()
            task.start(using: self)
        }
    }
}

extension UploadRemoteDataChangeOperation: RemoteDataChangeUploadingContext {

    // MARK: - RemoteDataChangeUploadingContext

    func pendingRemoteDataChanges() -> [RemoteChange] {
        return _pendingChanges
    }

    func didStartUploading(_ remoteChanges: [RemoteChange]) {
        internalQueue.async { [weak self] in
            self?._processingChanges = remoteChanges
            self?.storeInterface.purgeUploadedChanges(remoteChanges)
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
            self.storeInterface.restoreFailedChanges(changes)
        }
    }
}
