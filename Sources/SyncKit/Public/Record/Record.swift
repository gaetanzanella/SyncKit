
public protocol RecordID: Hashable {
    var storingKey: String { get }
}

public protocol Record {

    associatedtype ID: RecordID

    var id: ID { get }
}
