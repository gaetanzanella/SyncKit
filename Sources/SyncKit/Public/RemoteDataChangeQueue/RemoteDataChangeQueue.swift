
public enum RemoteDataChangeState {
    case pending, processing
}

public protocol RemoteDataChangeQueue {

    associatedtype RemoteChange: RemoteDataChange

    func changes(in state: RemoteDataChangeState) -> [RemoteChange]
    func changesCount(in state: RemoteDataChangeState) -> Int
    func add(_ changes: [RemoteChange], for state: RemoteDataChangeState)
    func remove(_ changes: [RemoteChange], for state: RemoteDataChangeState)
    func purgeAllChanges()
}
