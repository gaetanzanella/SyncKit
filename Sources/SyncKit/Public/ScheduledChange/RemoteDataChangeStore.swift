
public protocol RemoteDataChangeStore {

    associatedtype RemoteChange: RemoteDataChange

    func storedChanges() -> [RemoteChange]
    func changesCount() -> Int
    func store(_ changes: [RemoteChange])
    func purge(_ changes: [RemoteChange])
}
