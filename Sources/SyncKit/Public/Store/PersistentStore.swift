
public protocol PersistentStore {

    associatedtype Rec: Record

    func perform(_ changeset: RecordChangeset<Rec>) throws
}
