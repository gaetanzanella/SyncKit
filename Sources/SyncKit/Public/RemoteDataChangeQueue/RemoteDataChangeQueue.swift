
public protocol RemoteDataChangeQueue {

    associatedtype RemoteChange: RemoteDataChange

    func changes() -> [RemoteChange]
    func changesCount() -> Int
    func add(_ changes: [RemoteChange])
    func remove(_ changes: [RemoteChange])
}
