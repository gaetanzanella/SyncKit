
public protocol SynchronizationDependencyProvider {

    associatedtype RemoteChange
    associatedtype LocalChange
    associatedtype ConflictResolver: DataChangeConflictResolver where ConflictResolver.RemoteChange == RemoteChange, ConflictResolver.LocalChange == LocalChange
    associatedtype ChangeConverter: DataChangeConverter where ChangeConverter.RemoteChange == RemoteChange, ChangeConverter.LocalChange == LocalChange
    associatedtype ChangeQueue: RemoteDataChangeQueue where ChangeQueue.RemoteChange == RemoteChange
    associatedtype LocalStore: LocalDataStore where LocalStore.DataChange == LocalChange

    func makeRemoteChangeType() -> RemoteChange.Type
    func makeLocalChangeType() -> LocalChange.Type
    func makeConflictResolver() -> ConflictResolver
    func makeChangeConverter() -> ChangeConverter
    func makeRemoteDataChangeQueue() -> ChangeQueue
    func makeLocalDataStore() -> LocalStore
}
