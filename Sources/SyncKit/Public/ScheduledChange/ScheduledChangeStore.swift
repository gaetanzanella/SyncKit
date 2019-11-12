
public protocol ScheduledChangeStore {
    func storedChanges() -> [ScheduledChange]
    func changesCount() -> Int
    func store(_ changes: [ScheduledChange])
    func purge(_ changes: [ScheduledChange])
}
