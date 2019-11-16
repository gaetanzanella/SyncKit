
struct PersistentScheduledChange<ID: Codable>: Codable {

    enum Operation: String, Codable {
        case createOrModify, delete
    }

    let recordId: ID
    let operation: Operation
}
