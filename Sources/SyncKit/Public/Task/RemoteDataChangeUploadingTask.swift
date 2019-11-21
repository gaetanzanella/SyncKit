
public protocol RemoteDataChangeUploadingContext {

    associatedtype RemoteChange: RemoteDataChange

    func pendingRemoteDataChanges() -> [RemoteChange]
    func didStartUploading(_ remoteChanges: [RemoteChange])
    func didFinishUploading()
    func didFinishUploading(with error: Error)
    func endTask()
    func endTask(with error: Error)
}

public protocol UploadRemoteDataChangeTask {

    associatedtype RemoteChange: RemoteDataChange

    func start<C: RemoteDataChangeUploadingContext>(using context: C) where C.RemoteChange == RemoteChange
}
