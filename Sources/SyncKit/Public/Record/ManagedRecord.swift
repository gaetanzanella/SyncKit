
public protocol PendingChange {
    var storeIdentifier: String { get }
}

public protocol LocalChangeset {

    associatedtype Change: PendingChange

    func asRemoteChangeset() -> Change
}
