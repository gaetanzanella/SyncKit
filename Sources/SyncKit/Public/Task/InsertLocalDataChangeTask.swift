
public protocol LocalDataChangeInsertionContext {

    associatedtype LocalChange: LocalDataChange

    func didInsert(_ change: LocalChange)
    func endTask()
    func endTask(with error: Error)
}

public protocol InsertLocalDataChangeTask {

    associatedtype LocalChange: LocalDataChange

    func start<C: LocalDataChangeInsertionContext>(using context: C) where C.LocalChange == LocalChange
}
