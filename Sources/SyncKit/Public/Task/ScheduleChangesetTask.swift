
public protocol ScheduleChangesetTaskContext {
    func insert(_ changeset: RecordChangeset)
    func finish()
    func finish(with error: Error)
}

public protocol ScheduleChangesetTask {
    func execute(using context: ScheduleChangesetTaskContext)
}
