
import Foundation

class AsynchronousBlockOperation: AsynchronousOperation {

    typealias Completion = () -> Void

    private let task: (@escaping Completion) -> Void

    // MARK: - Lyfe Cycle

    init(task: @escaping (@escaping Completion) -> Void) {
        self.task = task
    }

    // MARK: - Public

    override func execute() {
        let completion = { [weak self] in
            self?.finish()
            return
        }
        task(completion)
    }
}
