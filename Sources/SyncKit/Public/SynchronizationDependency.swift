
public protocol SynchronizationDependency {

    associatedtype Record
    associatedtype Resolver: ScheduledChangeConflictResolver where Resolver.Rec == Record
    associatedtype Store: PersistentStore where Store.Rec == Record
    associatedtype ChangeStore: ScheduledChangeStore where ChangeStore.ID == Record.ID

    var conflictResolver: Resolver { get }
    var persistentStore: Store { get }
    var scheduledChangeStore: ChangeStore { get }
}
