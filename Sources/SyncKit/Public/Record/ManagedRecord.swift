
public protocol ManagedRecordID: Hashable {
    var storingKey: String { get }
}

public protocol ManagedRecord {

    associatedtype ID: ManagedRecordID

    var recordID: ID { get }
}
