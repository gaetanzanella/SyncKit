

public protocol DataChangeConverter {

    associatedtype LocalChange: LocalDataChange
    associatedtype RemoteChange: RemoteDataChange

    func remoteChanges(from localChange: LocalChange) -> [RemoteChange]
}
