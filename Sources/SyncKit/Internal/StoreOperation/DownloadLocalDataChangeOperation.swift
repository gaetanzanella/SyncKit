
import Foundation

protocol DownloadLocalDataChangeStoreInterface {

    associatedtype LocalChange: LocalDataChange

    func store(_ localChange: LocalChange) throws
}

class DownloadLocalDataChangeOperation<Task: DownloadLocalDataChangeTask, StoreInterface: DownloadLocalDataChangeStoreInterface>: SynchronizationOperation where Task.LocalChange == StoreInterface.LocalChange {

    let task: Task
    let storeInterface: StoreInterface

    private let internalQueue = DispatchQueue(label: "local_data_change_downloading_queue")

    init(task: Task,
         storeInterface: StoreInterface) {
        self.task = task
        self.storeInterface = storeInterface
        super.init(label: .download)
    }

    // MARK: - AsynchronousOperation

    override func startTask() {
        internalQueue.sync {
            let task = self.task
            task.start(using: self)
        }
    }
}

extension DownloadLocalDataChangeOperation: LocalDataChangeDownloadingContext {

    // MARK: - LocalDataChangeDownloadingContext

    func didDownload(_ change: Task.LocalChange) {
        internalQueue.async { [weak self] in
            do {
                try self?.storeInterface.store(change)
            } catch {
                self?.endTask(with: error)
            }
        }
    }
}
