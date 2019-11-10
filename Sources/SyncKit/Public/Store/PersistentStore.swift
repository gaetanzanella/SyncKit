
public protocol PersistentStore {
    func searchRecords(with ids: [Record.ID],
                       completion: @escaping (Result<[Record], Error>) -> Void)
    func perform(_ changeset: RecordChangeset,
                 completion: @escaping (Result<Void, Error>) -> Void)
}
