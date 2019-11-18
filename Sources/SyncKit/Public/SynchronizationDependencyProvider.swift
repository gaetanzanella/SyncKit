
public protocol SynchronizationDependencyProvider {

    associatedtype Changeset
    associatedtype ConflictResolver: ChangesetConflictResolver where ConflictResolver.Changeset == Changeset
    associatedtype ChangeStore: PendingChangeStore where ChangeStore.Change == Changeset.Change
    associatedtype PersistentStore: LocalPersistentStore where PersistentStore.Changeset == Changeset

    func makeConflictResolver() -> ConflictResolver
    func makeChangeStore() -> ChangeStore
    func makePersistentStore() -> PersistentStore
}
