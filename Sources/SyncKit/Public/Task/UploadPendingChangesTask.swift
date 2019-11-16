
public protocol UploadPendingChangesTaskContext {
    func pendingChanges() -> [ScheduledChange]
    func didStartUploading(_ changes: [ScheduledChange])
    func didFinishUploading()
    func didFinishUploading(with error: Error)
    func finish()
    func finish(with error: Error)
}

public protocol UploadPendingChangesTask {
    func execute(using context: UploadPendingChangesTaskContext)
}
