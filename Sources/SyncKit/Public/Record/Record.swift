
public extension Record {

    struct ID: Hashable {
        let identifier: String
        let recordName: Name
    }

    typealias Name = String
}


public struct Record {

    public let id: ID
    public var content: [String: Any]

    public init(id: ID,
                content: [String: Any] = [:]) {
        self.id = id
        self.content = content
    }

    subscript(key: String) -> Any? {
        get {
            content[key]
        }
        set {
            content[key] = newValue
        }
    }
}
