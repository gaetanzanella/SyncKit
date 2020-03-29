
public struct LocalDataChangeDownloadingContext<Change: LocalDataChange> {
    let didDownloadChangeHandler: (Change) -> Void
    let fulfillHandler: () -> Void
    let rejectHandler: (Error) -> Void
}

public extension LocalDataChangeDownloadingContext {

    func didDownload(_ localChange: Change) {
        didDownloadChangeHandler(localChange)
    }

    func endTask() {
        fulfillHandler()
    }

    func endTask(with error: Error) {
        rejectHandler(error)
    }
}

public protocol DownloadLocalDataChangeTask {

    associatedtype Change: LocalDataChange

    func start(using context: LocalDataChangeDownloadingContext<Change>)
}
