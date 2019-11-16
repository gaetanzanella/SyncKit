
public protocol ScheduleChangesetTaskContext {

    associatedtype Rec: Record

    func insert(_ changeset: RecordChangeset<Rec>)
    func finish()
    func finish(with error: Error)
}

public protocol ScheduleChangesetTask {
    func execute<Context: ScheduleChangesetTaskContext>(using context: Context)
}
