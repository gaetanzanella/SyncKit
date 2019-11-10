
public protocol UploadPendingChangesRoutine {
    func prepare(for changes: [ScheduledChange])
    func initialBatch() -> ScheduledChangeBatch
    func nextBatch(after batch: ScheduledChangeBatch) -> ScheduledChangeBatch?
    func finalize()
}
