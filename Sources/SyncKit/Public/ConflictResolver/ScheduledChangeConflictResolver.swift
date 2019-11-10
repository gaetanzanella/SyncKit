
public struct InsertedChangeConflit {
    public let insertedChanges: [ScheduledChange]
    public let pendingChangeset: [ScheduledChange]
}

public struct InsertedChangeConflictSolution {
    public let pendingChangesToCancel: [ScheduledChange]
}

public struct FailedChangeConflit {
    public let failedChangeset: [ScheduledChange]
    public let pendingChanges: [ScheduledChange]
}

public struct FailedChangeConflitSolution {
    public let changesToRestore: [ScheduledChange]
}

public struct FetchedChangeConflit {
    public let newChangeset: RecordChangeset
    public let pendingChanges: [ScheduledChange]
}

public struct FetchedChangeConflictSolution {
    public let newChangesToPersist: RecordChangeset
    public let pendingChangesToCancel: [ScheduledChange]
}

public protocol ScheduledChangeConflictResolver {
    /// When a new pending change is created, which pending changes to cancel?
    func resolve(_ conflit: InsertedChangeConflit) -> InsertedChangeConflictSolution
    /// When pending changes failed, which ones are still valid?
    func resolve(_ conflit: FailedChangeConflit) -> FailedChangeConflitSolution
    /// When new changes are fetched, which pending changes to keep? which fetched changes to persist?
    func resolve(_ conflit: FetchedChangeConflit) -> FetchedChangeConflictSolution
}
