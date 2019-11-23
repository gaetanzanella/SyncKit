
public protocol SynchronizationDependencyProvider {

    associatedtype RemoteChange
    associatedtype LocalChange
    associatedtype ConflictResolver: DataChangeConflictResolver where ConflictResolver.RemoteChange == RemoteChange, ConflictResolver.LocalChange == LocalChange
    associatedtype ChangeConverter: DataChangeConverter where ChangeConverter.RemoteChange == RemoteChange, ChangeConverter.LocalChange == LocalChange
    associatedtype ChangeStore: RemoteDataChangeStore where ChangeStore.RemoteChange == RemoteChange
    associatedtype LocalStore: LocalDataStore where LocalStore.DataChange == LocalChange

    func remoteChangeType() -> RemoteChange.Type
    func localChangeType() -> LocalChange.Type
    func makeConflictResolver() -> ConflictResolver
    func makeChangeConverter() -> ChangeConverter
    func makeRemoteDataChangeStore() -> ChangeStore
    func makeLocalDataStore() -> LocalStore
}
