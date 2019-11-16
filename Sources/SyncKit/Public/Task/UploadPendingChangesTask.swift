
public protocol UploadPendingChangesTaskContext {

    associatedtype ID: RecordID

    func pendingChanges() -> ScheduledChangeBatch<ID>
    func didStartUploading(_ batch: ScheduledChangeBatch<ID>)
    func didFinishUploading()
    func didFinishUploading(with error: Error)
    func finish()
    func finish(with error: Error)
}

public protocol UploadPendingChangesTask {
    func execute<Context: UploadPendingChangesTaskContext>(using context: Context)
}
