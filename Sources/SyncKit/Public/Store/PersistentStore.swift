
public protocol PersistentStore {
    func searchRecords(with ids: [Record.ID]) throws -> [Record.ID: Record]
    func perform(_ changeset: RecordChangeset) throws
}
