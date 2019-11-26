
import Foundation

protocol InsertLocalDataChangeStoreInterface {

    associatedtype LocalChange: LocalDataChange

    func insert(_ localChange: LocalChange) throws
}

class InsertLocalDataChangeOperation<Task: InsertLocalDataChangeTask, StoreInterface: InsertLocalDataChangeStoreInterface>: SynchronizationOperation where Task.Change == StoreInterface.LocalChange {

    private let task: Task
    private let storeInterface: StoreInterface

    private let internalQueue = DispatchQueue(label: "local_data_change_insertion_queue")

    init(task: Task,
         storeInterface: StoreInterface) {
        self.task = task
        self.storeInterface = storeInterface
        super.init(label: .insertion)
    }

    // MARK: - SynchronizationOperation

    override func startTask() {
        internalQueue.sync {
            task.start(using: self)
        }
    }
}

extension InsertLocalDataChangeOperation: LocalDataChangeInsertionContext {

    // MARK: - InsertChangesetTaskContext

    func didInsert(_ localChange: Task.Change) {
        internalQueue.async { [weak self] in
            do {
                try self?.storeInterface.insert(localChange)
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
