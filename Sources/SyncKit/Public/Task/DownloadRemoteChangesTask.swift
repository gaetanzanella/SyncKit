
public protocol DownloadRemoteChangesContext {

    associatedtype Record: ManagedRecord

    func didDownloadChangeset(_ changeset: RecordChangeset<Record>)
    func endTask()
    func endTask(with error: Error)
}

public protocol DownloadRemoteChangesTask {

    associatedtype Record: ManagedRecord

    func start<Context: DownloadRemoteChangesContext>(using context: Context) where Context.Record == Record
}

