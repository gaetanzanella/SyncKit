
public struct InsertionConflit<RemoteChange: RemoteDataChange> {

    public let insertedChanges: [RemoteChange]
    public let pendingChanges: [RemoteChange]

    init(insertedChanges: [RemoteChange],
         pendingChanges: [RemoteChange]) {
        self.insertedChanges = insertedChanges
        self.pendingChanges = pendingChanges
    }
}

public struct InsertionConflitSolution<RemoteChange: RemoteDataChange> {

    public let pendingChangesToCancel: [RemoteChange]

    public init(pendingChangesToCancel: [RemoteChange]) {
        self.pendingChangesToCancel = pendingChangesToCancel
    }
}

public struct UploadingFailureConflit<RemoteChange: RemoteDataChange> {

    public let failedChanges: [RemoteChange]
    public let pendingChanges: [RemoteChange]

    init(failedChanges: [RemoteChange],
         pendingChanges: [RemoteChange]) {
        self.failedChanges = failedChanges
        self.pendingChanges = pendingChanges
    }
}

public struct UploadingFailureConflitSolution<RemoteChange: RemoteDataChange> {

    public let changesToRestore: [RemoteChange]

    public init(changesToRestore: [RemoteChange]) {
        self.changesToRestore = changesToRestore
    }
}

public struct DownloadingConflit<LocalChange: LocalDataChange, RemoteChange: RemoteDataChange> {

    public let newChange: LocalChange
    public let pendingChanges: [RemoteChange]

    init(newChange: LocalChange,
         pendingChanges: [RemoteChange]) {
        self.newChange = newChange
        self.pendingChanges = pendingChanges
    }
}

public struct DownloadingConflitSolution<LocalChange: LocalDataChange, RemoteChange: RemoteDataChange> {

    public let newChangeToPersist: LocalChange
    public let pendingChangesToCancel: [RemoteChange]

    public init(newChangeToPersist: LocalChange,
                pendingChangesToCancel: [RemoteChange]) {
        self.newChangeToPersist = newChangeToPersist
        self.pendingChangesToCancel = pendingChangesToCancel
    }
}

public protocol DataChangeConflictResolver {

    associatedtype LocalChange: LocalDataChange
    associatedtype RemoteChange: RemoteDataChange

    /// When a new pending change is created, which pending changes to cancel?
    func resolve(_ conflit: InsertionConflit<RemoteChange>) -> InsertionConflitSolution<RemoteChange>
    /// When pending changes failed, which ones are still valid?
    func resolve(_ conflit: UploadingFailureConflit<RemoteChange>) -> UploadingFailureConflitSolution<RemoteChange>
    /// When new changes are fetched, which pending changes to keep? which fetched changes to persist?
    func resolve(_ conflit: DownloadingConflit<LocalChange, RemoteChange>) -> DownloadingConflitSolution<LocalChange, RemoteChange>
}
