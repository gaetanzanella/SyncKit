
public protocol DownloadRemoteChangesContext {
    func didDownloadChangeset(_ changeset: RecordChangeset)
    func finish()
    func finish(with error: Error)
}

public protocol DownloadRemoteChangesTask {
    func execute(using context: DownloadRemoteChangesContext)
}

