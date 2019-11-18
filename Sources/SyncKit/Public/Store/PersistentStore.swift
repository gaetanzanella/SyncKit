
public protocol LocalPersistentStore {

    associatedtype Changeset: LocalChangeset

    func perform(_ changeset: Changeset) throws
}
