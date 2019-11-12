
import Foundation

extension OperationQueue {
    func addAsynchronousOperation(task: @escaping (@escaping AsynchronousBlockOperation.Completion) -> Void) {
        let operation = AsynchronousBlockOperation(task: task)
        addOperation(operation)
    }
}
