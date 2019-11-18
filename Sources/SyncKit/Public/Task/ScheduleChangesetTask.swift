
public protocol ScheduleLocalChangesetTaskContext {

    associatedtype Changeset: LocalChangeset

    func didInsert(_ changeset: Changeset)
    func endTask()
    func endTask(with error: Error)
}

public protocol ScheduleLocalChangesetTask {

    associatedtype Changeset: LocalChangeset

    func start<Context: ScheduleLocalChangesetTaskContext>(using context: Context) where Context.Changeset == Changeset
}
