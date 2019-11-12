
extension ScheduledChange.Operation {

    var storingKey: Int {
        switch self {
        case .createOrModify:
            return 0
        case .delete:
            return 1
        }
    }
}

extension ScheduledChange {

    func toPersistentChange() -> PersistentScheduledChange {
        PersistentScheduledChange(
            recordId: recordID.toPersistentID(),
            operation: operation.toPersistentOperation()
        )
    }

    var storingKey: String {
        "\(recordID.recordName)_\(recordID.identifier)_\(operation.storingKey)"
    }
}

extension Record.ID {

    func toPersistentID() -> PersistentScheduledChange.ID {
        PersistentScheduledChange.ID(
            identifier: identifier,
            name: recordName
        )
    }
}

extension ScheduledChange.Operation {

    func toPersistentOperation() -> PersistentScheduledChange.Operation {
        switch self {
        case .createOrModify:
            return .createOrModify
        case .delete:
            return .delete
        }
    }
}

extension PersistentScheduledChange {

    func toChange() -> ScheduledChange {
        ScheduledChange(
            recordID: recordId.toID(),
            operation: operation.toOperation()
        )
    }
}

extension PersistentScheduledChange.ID {

    func toID() -> Record.ID {
        Record.ID(
            identifier: identifier,
            recordName: name
        )
    }
}

extension PersistentScheduledChange.Operation {

    func toOperation() -> ScheduledChange.Operation {
        switch self {
        case .createOrModify:
            return .createOrModify
        case .delete:
            return .delete
        }
    }
}
