
public struct InsertedLocalChangesetConflit<Changeset: LocalChangeset> {

    public let insertedChangeset: Changeset
    public let pendingChanges: [Changeset.Change]

    public init(insertedChangeset: Changeset,
                pendingChanges: [Changeset.Change]) {
        self.insertedChangeset = insertedChangeset
        self.pendingChanges = pendingChanges
    }
}

public struct InsertedLocalChangesetConflitSolution<Changeset: LocalChangeset> {

    public let pendingChangesToCancel: [Changeset.Change]

    public init(pendingChangesToCancel: [Changeset.Change]) {
        self.pendingChangesToCancel = pendingChangesToCancel
    }
}

public struct FailedPendingChangesUploadConflit<Change: PendingChange> {

    public let failedChanges: [Change]
    public let pendingChanges: [Change]

    public init(failedChanges: [Change],
                pendingChanges: [Change]) {
        self.failedChanges = failedChanges
        self.pendingChanges = pendingChanges
    }
}

public struct FailedPendingChangesUploadConflitSolution<Change: PendingChange> {

    public let changesToRestore: [Change]

    public init(changesToRestore: [Change]) {
        self.changesToRestore = changesToRestore
    }
}

public struct FetchedLocalChangesetConflit<Changeset: LocalChangeset> {

    public let newChangeset: Changeset
    public let pendingChanges: [Changeset.Change]

    public init(newChangeset: Changeset,
                pendingChanges: [Changeset.Change]) {
        self.newChangeset = newChangeset
        self.pendingChanges = pendingChanges
    }
}

public struct FetchedLocalChangesetConflitSolution<Changeset: LocalChangeset> {

    public let newChangesToPersist: Changeset
    public let pendingChangesToCancel: [Changeset.Change]

    public init(newChangesToPersist: Changeset,
         pendingChangesToCancel: [Changeset.Change]) {
        self.newChangesToPersist = newChangesToPersist
        self.pendingChangesToCancel = pendingChangesToCancel
    }
}

public protocol ChangesetConflictResolver {

    associatedtype Changeset: LocalChangeset

    /// When a new pending change is created, which pending changes to cancel?
    func resolve(_ conflit: InsertedLocalChangesetConflit<Changeset>) -> InsertedLocalChangesetConflitSolution<Changeset>
    /// When pending changes failed, which ones are still valid?
    func resolve(_ conflit: FailedPendingChangesUploadConflit<Changeset.Change>) -> FailedPendingChangesUploadConflitSolution<Changeset.Change>
    /// When new changes are fetched, which pending changes to keep? which fetched changes to persist?
    func resolve(_ conflit: FetchedLocalChangesetConflit<Changeset>) -> FetchedLocalChangesetConflitSolution<Changeset>
}
