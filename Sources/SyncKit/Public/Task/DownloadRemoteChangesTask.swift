
public protocol DownloadRemoteChangesContext {

    associatedtype Rec: Record

    func didDownloadChangeset(_ changeset: RecordChangeset<Rec>)
    func finish()
    func finish(with error: Error)
}

public protocol DownloadRemoteChangesTask {
    func execute<Context: DownloadRemoteChangesContext>(using context: Context)
}

