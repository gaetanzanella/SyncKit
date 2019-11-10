
public protocol RemoteStore {
    func fetchChanges(forRecordsNamed names: [Record.Name],
                      completion: @escaping (Result<RecordChangeset, Error>) -> Void)
    func perform(_ changeset: RecordChangeset,
                 completion: @escaping (Result<Void, Error>) -> Void)
}
