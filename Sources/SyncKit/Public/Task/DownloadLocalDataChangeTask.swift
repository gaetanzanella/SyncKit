
public protocol LocalDataChangeDownloadingContext {

    associatedtype LocalChange: LocalDataChange

    func didDownload(_ localChange: LocalChange)
    func endTask()
    func endTask(with error: Error)
}

public protocol DownloadLocalDataChangeTask {

    associatedtype LocalChange: LocalDataChange

    func start<C: LocalDataChangeDownloadingContext>(using context: C) where C.LocalChange == LocalChange
}
