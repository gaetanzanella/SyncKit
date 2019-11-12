
struct PersistentScheduledChange: Codable {

    struct ID: Codable {
        let identifier: String
        let name: String
    }

    enum Operation: String, Codable {
        case createOrModify, delete
    }

    let recordId: ID
    let operation: Operation
}
