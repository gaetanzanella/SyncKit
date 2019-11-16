
public struct RecordChangeset<R: Record> {

    public var recordsToSave: [R]
    public var recordIDsToDelete: [R.ID]

    public init(recordsToSave: [R] = [],
                recordIDsToDelete: [R.ID] = []) {
        self.recordsToSave = recordsToSave
        self.recordIDsToDelete = recordIDsToDelete
    }

    public mutating func appendRecordToSave(_ record: R) {
        recordsToSave.append(record)
    }

    public mutating func appendRecordIDToSave(_ recordId: R.ID) {
        recordIDsToDelete.append(recordId)
    }
}
