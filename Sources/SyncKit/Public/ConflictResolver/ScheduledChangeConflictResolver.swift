
public struct InsertedChangeConflit<Record: ManagedRecord> {

    public let insertedChangeset: RecordChangeset<Record>
    public let pendingChanges: ScheduledChangeBatch<Record.ID>

    public init(insertedChangeset: RecordChangeset<Record>,
                pendingChanges: ScheduledChangeBatch<Record.ID>) {
        self.insertedChangeset = insertedChangeset
        self.pendingChanges = pendingChanges
    }
}

public struct InsertedChangeConflictSolution<Record: ManagedRecord> {

    public let pendingChangesToCancel: [ScheduledChange<Record.ID>]

    public init(pendingChangesToCancel: [ScheduledChange<Record.ID>]) {
        self.pendingChangesToCancel = pendingChangesToCancel
    }
}

public struct FailedChangeConflit<Record: ManagedRecord> {

    public let failedChanges: ScheduledChangeBatch<Record.ID>
    public let pendingChanges: ScheduledChangeBatch<Record.ID>

    public init(failedChanges: ScheduledChangeBatch<Record.ID>,
                pendingChanges: ScheduledChangeBatch<Record.ID>) {
        self.failedChanges = failedChanges
        self.pendingChanges = pendingChanges
    }
}

public struct FailedChangeConflitSolution<Record: ManagedRecord> {

    public let changesToRestore: [ScheduledChange<Record.ID>]

    public init(changesToRestore: [ScheduledChange<Record.ID>]) {
        self.changesToRestore = changesToRestore
    }
}

public struct FetchedChangeConflit<Record: ManagedRecord> {

    public let newChangeset: RecordChangeset<Record>
    public let pendingChanges: ScheduledChangeBatch<Record.ID>

    public init(newChangeset: RecordChangeset<Record>,
         pendingChanges: ScheduledChangeBatch<Record.ID>) {
        self.newChangeset = newChangeset
        self.pendingChanges = pendingChanges
    }
}

public struct FetchedChangeConflictSolution<Record: ManagedRecord> {

    public let newChangesToPersist: RecordChangeset<Record>
    public let pendingChangesToCancel: [ScheduledChange<Record.ID>]

    public init(newChangesToPersist: RecordChangeset<Record>,
         pendingChangesToCancel: [ScheduledChange<Record.ID>]) {
        self.newChangesToPersist = newChangesToPersist
        self.pendingChangesToCancel = pendingChangesToCancel
    }
}

public protocol ScheduledChangeConflictResolver {

    associatedtype Record: ManagedRecord

    /// When a new pending change is created, which pending changes to cancel?
    func resolve(_ conflit: InsertedChangeConflit<Record>) -> InsertedChangeConflictSolution<Record>
    /// When pending changes failed, which ones are still valid?
    func resolve(_ conflit: FailedChangeConflit<Record>) -> FailedChangeConflitSolution<Record>
    /// When new changes are fetched, which pending changes to keep? which fetched changes to persist?
    func resolve(_ conflit: FetchedChangeConflit<Record>) -> FetchedChangeConflictSolution<Record>
}
