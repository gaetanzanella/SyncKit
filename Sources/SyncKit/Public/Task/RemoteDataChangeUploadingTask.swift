
public struct RemoteDataChangeUploadingContext<Change: RemoteDataChange> {
    let pendingRemoteDataChangesHandler: () -> [Change]
    let didStartUploadingHandler: ([Change]) -> Void
    let didFinishUploadingHandler: () -> Void
    let didFinishUploadingWithErrorHandler: (Error) -> Void
    let fulfillHandler: () -> Void
    let rejectHandler: (Error) -> Void
}

public extension RemoteDataChangeUploadingContext {

    func pendingRemoteDataChanges() -> [Change] {
        pendingRemoteDataChangesHandler()
    }

    func didStartUploading(_ remoteChanges: [Change]) {
        didStartUploadingHandler(remoteChanges)
    }

    func didFinishUploading() {
        didFinishUploadingHandler()
    }

    func didFinishUploading(with error: Error) {
        didFinishUploadingWithErrorHandler(error)
    }

    func endTask() {
        fulfillHandler()
    }

    func endTask(with error: Error) {
        rejectHandler(error)
    }
}

public protocol UploadRemoteDataChangeTask {

    associatedtype Change: RemoteDataChange

    func start(using context: RemoteDataChangeUploadingContext<Change>)
}
