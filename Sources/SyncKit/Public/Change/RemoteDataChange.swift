
public protocol RemoteDataChangeID: Hashable {}

public protocol RemoteDataChange: Hashable {

    associatedtype ID: RemoteDataChangeID

    var id: ID { get }
}
