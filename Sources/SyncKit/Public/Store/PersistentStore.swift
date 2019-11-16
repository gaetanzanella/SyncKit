
public protocol PersistentStore {

    associatedtype R: Record

    func perform(_ changeset: RecordChangeset<R>) throws
}
