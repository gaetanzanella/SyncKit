
public struct InsertedChangeConflit<Rec: Record> {
    public let insertedChangeset: RecordChangeset<Rec>
    public let pendingChanges: ScheduledChangeBatch<Rec.ID>
}

public struct InsertedChangeConflictSolution<Rec: Record> {
    public let pendingChangesToCancel: ScheduledChangeBatch<Rec.ID>
}

public struct FailedChangeConflit<Rec: Record> {
    public let failedChanges: ScheduledChangeBatch<Rec.ID>
    public let pendingChanges: ScheduledChangeBatch<Rec.ID>
}

public struct FailedChangeConflitSolution<Rec: Record> {
    public let changesToRestore: ScheduledChangeBatch<Rec.ID>
}

public struct FetchedChangeConflit<Rec: Record> {
    public let newChangeset: RecordChangeset<Rec>
    public let pendingChanges: ScheduledChangeBatch<Rec.ID>
}

public struct FetchedChangeConflictSolution<Rec: Record> {
    public let newChangesToPersist: RecordChangeset<Rec>
    public let pendingChangesToCancel: ScheduledChangeBatch<Rec.ID>
}

public protocol ScheduledChangeConflictResolver {

    associatedtype Rec: Record

    /// When a new pending change is created, which pending changes to cancel?
    func resolve(_ conflit: InsertedChangeConflit<Rec>) -> InsertedChangeConflictSolution<Rec>
    /// When pending changes failed, which ones are still valid?
    func resolve(_ conflit: FailedChangeConflit<Rec>) -> FailedChangeConflitSolution<Rec>
    /// When new changes are fetched, which pending changes to keep? which fetched changes to persist?
    func resolve(_ conflit: FetchedChangeConflit<Rec>) -> FetchedChangeConflictSolution<Rec>
}
