
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

extension ScheduledChange where ID: Codable {

    func toPersistentChange() -> PersistentScheduledChange<ID> {
        PersistentScheduledChange(
            recordId: recordID,
            operation: operation.toPersistentOperation()
        )
    }

    var storingKey: String {
        "\(recordID.storingKey)_\(operation.storingKey)"
    }
}

extension ScheduledChange.Operation where ID: Codable {

    func toPersistentOperation() -> PersistentScheduledChange<ID>.Operation {
        switch self {
        case .createOrModify:
            return .createOrModify
        case .delete:
            return .delete
        }
    }
}

extension PersistentScheduledChange where ID: ManagedRecordID {

    func toChange() -> ScheduledChange<ID> {
        ScheduledChange(
            recordID: recordId,
            operation: operation.toOperation()
        )
    }
}

extension PersistentScheduledChange.Operation where ID: ManagedRecordID {

    func toOperation() -> ScheduledChange<ID>.Operation {
        switch self {
        case .createOrModify:
            return .createOrModify
        case .delete:
            return .delete
        }
    }
}
