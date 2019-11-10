
public class SynchronizationContext {
    public func downloadRemoteChanges(completion: @escaping (Result<Void, Error>) -> Void) {}
    public func uploadPendingChanges(completion: @escaping (Result<Void, Error>) -> Void) {}
    public func schedule(_ changeset: RecordChangeset,
                         completion: @escaping (Result<Void, Error>) -> Void) {}
}
