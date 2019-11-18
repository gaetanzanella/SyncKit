
public protocol UploadChangesTaskContext {

    associatedtype Change: PendingChange

    func pendingChanges() -> [Change]
    func didStartUploading(_ batch: [Change])
    func didFinishUploading()
    func didFinishUploading(with error: Error)
    func endTask()
    func endTask(with error: Error)
}

public protocol UploadChangesTask {

    associatedtype Change: PendingChange

    func start<Context: UploadChangesTaskContext>(using context: Context) where Context.Change == Change
}
