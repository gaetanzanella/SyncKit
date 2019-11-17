
public protocol PersistentStore {

    associatedtype Record: ManagedRecord

    func perform(_ changeset: RecordChangeset<Record>) throws
}
