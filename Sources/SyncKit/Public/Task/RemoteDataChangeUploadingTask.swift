
public protocol RemoteDataChangeUploadingContext {

    associatedtype Change: RemoteDataChange

    func pendingRemoteDataChanges() -> [Change]
    func didStartUploading(_ remoteChanges: [Change])
    func didFinishUploading()
    func didFinishUploading(with error: Error)
    func endTask()
    func endTask(with error: Error)
}

public protocol UploadRemoteDataChangeTask {

    associatedtype Change: RemoteDataChange

    func start<C: RemoteDataChangeUploadingContext>(using context: C) where C.Change == Change
}
