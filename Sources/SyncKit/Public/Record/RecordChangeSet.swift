
public struct RecordChangeset {

    public var recordsToSave: [Record]
    public var recordIDsToDelete: [Record.ID]

    public init() {
        recordsToSave = []
        recordIDsToDelete = []
    }

    public mutating func appendRecordToSave(_ record: Record) {
        recordsToSave.append(record)
    }

    public mutating func appendRecordIDToSave(_ recordId: Record.ID) {
        recordIDsToDelete.append(recordId)
    }
}
