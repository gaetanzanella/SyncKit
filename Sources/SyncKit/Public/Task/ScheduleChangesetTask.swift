
public protocol ScheduleChangesetTaskContext {

    associatedtype Record: ManagedRecord

    func didInsert(_ changeset: RecordChangeset<Record>)
    func endTask()
    func endTask(with error: Error)
}

public protocol ScheduleChangesetTask {

    associatedtype Record: ManagedRecord

    func start<Context: ScheduleChangesetTaskContext>(using context: Context) where Context.Record == Record
}
