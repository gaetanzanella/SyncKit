
import Foundation

class SynchronizationOperation: AsynchronousOperation {

    // MARK: - Public properties

    enum Label {
        case upload, download, insertion
    }

    let label: Label

    var startBlock: (() -> Void)?
    var finishBlock: ((Error?) -> Void)?

    // MARK: - Life Cycle

    init(label: Label) {
        self.label = label
    }

    // MARK: - SynchronizationOperation

    func startTask() {
        // override
    }

    final func endTask() {
        finishBlock?(nil)
        finish()
    }

    final func endTask(with error: Error) {
        finishBlock?(error)
        finish()
    }

    // MARK: - AsynchronousOperation

    override func execute() {
        startBlock?()
        startTask()
    }
}
