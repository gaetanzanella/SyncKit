
public protocol ScheduledChangeStore {

    associatedtype ID: ManagedRecordID

    func storedChanges() -> [ScheduledChange<ID>]
    func changesCount() -> Int
    func store(_ changes: [ScheduledChange<ID>])
    func purge(_ changes: [ScheduledChange<ID>])
}
