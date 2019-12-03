
public struct LocalDataChangeInsertionContext<Change: LocalDataChange> {
    let didInsertChangeHandler: (Change) -> Void
    let fulfillHandler: () -> Void
    let rejectHandler: (Error) -> Void
}

public extension LocalDataChangeInsertionContext {

    func didInsert(_ change: Change) {
        didInsertChangeHandler(change)
    }

    func endTask() {
        fulfillHandler()
    }

    func endTask(with error: Error) {
        rejectHandler(error)
    }
}

public protocol InsertLocalDataChangeTask {

    associatedtype Change: LocalDataChange

    func start(using context: LocalDataChangeInsertionContext<Change>)
}
