
public protocol DownloadLocalChangesetContext {

    associatedtype Changeset: LocalChangeset

    func didDownloadChangeset(_ changeset: Changeset)
    func endTask()
    func endTask(with error: Error)
}

public protocol DownloadLocalChangesetTask {

    associatedtype Changeset: LocalChangeset

    func start<Context: DownloadLocalChangesetContext>(using context: Context) where Context.Changeset == Changeset
}

