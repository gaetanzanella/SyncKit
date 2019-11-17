
public protocol SynchronizationDependencyProvider {

    associatedtype Record
    associatedtype ConflictResolver: ScheduledChangeConflictResolver where ConflictResolver.Record == Record
    associatedtype ChangeStore: ScheduledChangeStore where ChangeStore.ID == Record.ID
    associatedtype Store: PersistentStore where Store.Record == Record

    func makeConflictResolver() -> ConflictResolver
    func makeChangeStore() -> ChangeStore
    func makePersistentStore() -> Store
}
