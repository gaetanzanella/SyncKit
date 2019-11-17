
public struct ScheduledChange<ID: ManagedRecordID>: Hashable {

    public enum Operation {
        case createOrModify
        case delete
    }

    public let recordID: ID
    public let operation: Operation

    internal init(recordID: ID, operation: Operation) {
        self.recordID = recordID
        self.operation = operation
    }
}

public struct ScheduledChangeBatch<ID: ManagedRecordID> {

    // MARK: - Public properties

    public let changes: [ScheduledChange<ID>]

    // MARK: - Life Cycle

    public init(_ changes: [ScheduledChange<ID>]) {
        self.changes = changes
    }

    // MARK: - Filters by record ID

    public func containsChanges(for recordID: ID) -> Bool {
        return changes.contains(where: { $0.recordID == recordID })
    }

    public func change(for recordID: ID) -> ScheduledChange<ID>? {
        return changes.first { $0.recordID == recordID }
    }

    public func changes(for recordID: ID) -> [ScheduledChange<ID>] {
        return changes.filter { $0.recordID == recordID }
    }

    // MARK: - Filters by operation

    public func containsChanges(for operation: ScheduledChange<ID>.Operation) -> Bool {
        return changes.contains(where: { $0.operation == operation })
    }

    public func change(for operation: ScheduledChange<ID>.Operation) -> ScheduledChange<ID>? {
        return changes.first { $0.operation == operation }
    }

    public func changes(for operation: ScheduledChange<ID>.Operation) -> [ScheduledChange<ID>] {
        return changes.filter { $0.operation == operation }
    }
}
