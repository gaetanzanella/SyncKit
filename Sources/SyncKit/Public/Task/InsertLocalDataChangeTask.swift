
public protocol LocalDataChangeInsertionContext {

    associatedtype Change: LocalDataChange

    func didInsert(_ change: Change)
    func endTask()
    func endTask(with error: Error)
}

public protocol InsertLocalDataChangeTask {

    associatedtype Change: LocalDataChange

    func start<C: LocalDataChangeInsertionContext>(using context: C) where C.Change == Change
}
