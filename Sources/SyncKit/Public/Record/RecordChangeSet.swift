
public struct RecordChangeset<Record: ManagedRecord> {

    public var recordsToSave: [Record]
    public var recordIDsToDelete: [Record.ID]

    public init(recordsToSave: [Record] = [],
                recordIDsToDelete: [Record.ID] = []) {
        self.recordsToSave = recordsToSave
        self.recordIDsToDelete = recordIDsToDelete
    }

    public mutating func appendRecordToSave(_ record: Record) {
        recordsToSave.append(record)
    }

    public mutating func appendRecordIDToSave(_ recordId: Record.ID) {
        recordIDsToDelete.append(recordId)
    }

    public func recordIDs() -> [Record.ID] {
        return recordIDsToDelete + recordsToSave.map { $0.recordID }
    }
}
