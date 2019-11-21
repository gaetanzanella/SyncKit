
public protocol LocalDataStore {

    associatedtype DataChange: LocalDataChange

    func perform(_ dataChange: DataChange) throws
}
