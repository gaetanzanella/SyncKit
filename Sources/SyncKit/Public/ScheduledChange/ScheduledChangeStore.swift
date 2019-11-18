
public protocol PendingChangeStore {

    associatedtype Change: PendingChange

    func storedChanges() -> [Change]
    func changesCount() -> Int
    func store(_ changes: [Change])
    func purge(_ changes: [Change])
}
