
public protocol UploadPendingChangesTaskContext {

    associatedtype ID: ManagedRecordID

    func pendingChanges() -> ScheduledChangeBatch<ID>
    func didStartUploading(_ batch: ScheduledChangeBatch<ID>)
    func didFinishUploading()
    func didFinishUploading(with error: Error)
    func endTask()
    func endTask(with error: Error)
}

public protocol UploadPendingChangesTask {

    associatedtype Record: ManagedRecord

    func start<Context: UploadPendingChangesTaskContext>(using context: Context) where Context.ID == Record.ID
}
