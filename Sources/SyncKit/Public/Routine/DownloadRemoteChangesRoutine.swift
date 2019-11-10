
public protocol DownloadRemoteChangesRoutine {
    func prepare()
    func initialDownloadedRecordNames() -> [Record.Name]
    func nextDownloadedRecordNames(after recordNames: [Record.Name]) -> [Record.Name]?
    func finalize()
}
