
public protocol LocalDataChangeDownloadingContext {

    associatedtype Change: LocalDataChange

    func didDownload(_ localChange: Change)
    func endTask()
    func endTask(with error: Error)
}

public protocol DownloadLocalDataChangeTask {

    associatedtype Change: LocalDataChange

    func start<C: LocalDataChangeDownloadingContext>(using context: C) where C.Change == Change
}
