
public struct ScheduledChange {

    public enum Operation {
        case createOrModify
        case delete
    }

    public let recordID: Record.ID
    public let operation: Operation
}

public struct ScheduledChangeBatch {

    public let changes: [ScheduledChange]

    public init(_ changes: [ScheduledChange]) {
        self.changes = changes
    }

    public func containsChanges(for name: Record.Name) -> Bool {
        return changes.contains(where: { $0.recordID.recordName == name })
    }

    public func change(for name: Record.Name) -> ScheduledChange? {
        return changes.first { $0.recordID.recordName == name }
    }

    public func changes(for name: Record.Name) -> [ScheduledChange] {
        return changes.filter { $0.recordID.recordName == name }
    }

    public func containsChanges(for recordID: Record.ID) -> Bool {
        return changes.contains(where: { $0.recordID == recordID })
    }

    public func change(for recordID: Record.ID) -> ScheduledChange? {
        return changes.first { $0.recordID == recordID }
    }

    public func changes(for recordID: Record.ID) -> [ScheduledChange] {
        return changes.filter { $0.recordID == recordID }
    }
}
