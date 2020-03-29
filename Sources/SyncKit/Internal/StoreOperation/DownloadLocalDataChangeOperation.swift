
import Foundation

protocol DownloadLocalDataChangeStoreInterface {

    associatedtype LocalChange: LocalDataChange

    func store(_ localChange: LocalChange) throws
}

class DownloadLocalDataChangeOperation<Task: DownloadLocalDataChangeTask, StoreInterface: DownloadLocalDataChangeStoreInterface>: SynchronizationOperation where Task.Change == StoreInterface.LocalChange {

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
            let context = LocalDataChangeDownloadingContext(
                didDownloadChangeHandler: { [weak self] change in
                    self?.didDownload(change)
                },
                fulfillHandler: { [weak self] in
                    self?.fulfill()
                },
                rejectHandler: { [weak self] error in
                    self?.reject(with: error)
                }
            )
            task.start(using: context)
        }
    }

    // MARK: - DownloadLocalDataChangeOperation

    func didDownload(_ change: Task.Change) {
        internalQueue.async { [weak self] in
            do {
                try self?.storeInterface.store(change)
            } catch {
                self?.endTask(with: error)
            }
        }
    }

    func fulfill() {
        internalQueue.async { [weak self] in
            self?.endTask()
        }
    }

    func reject(with error: Error) {
        internalQueue.async { [weak self] in
            self?.endTask(with: error)
        }
    }
}
