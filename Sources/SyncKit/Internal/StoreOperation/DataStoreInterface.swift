
class DataStoreInterface<DependencyProvider: SynchronizationDependencyProvider>: UploadRemoteDataChangeStoreInterface,
    DownloadLocalDataChangeStoreInterface,
    InsertLocalDataChangeStoreInterface {

    var changeUpdateHandler: ((Int) -> Void)?

    typealias RemoteChange = DependencyProvider.RemoteChange
    typealias LocalChange = DependencyProvider.LocalChange

    private let dependancyProvider: DependencyProvider

    private var localStore: DependencyProvider.LocalStore {
        dependancyProvider.makeLocalDataStore()
    }

    private var resolver: DependencyProvider.ConflictResolver {
        dependancyProvider.makeConflictResolver()
    }

    private var converter: DependencyProvider.ChangeConverter {
        dependancyProvider.makeChangeConverter()
    }

    private let storeCoordinator: RemoteDataChangeStoreCoordinator<DependencyProvider.ChangeQueue>

    init(dependancyProvider: DependencyProvider) {
        self.dependancyProvider = dependancyProvider
        self.storeCoordinator = RemoteDataChangeStoreCoordinator(
            store: dependancyProvider.makeRemoteDataChangeQueue()
        )
    }

    // MARK: - UploadRemoteDataChangeStoreInterface

    func pendingChanges() -> [RemoteChange] {
        var changes: [RemoteChange] = []
        storeCoordinator.coordinateReading { store in
            changes = store.pendingStoredChanges()
        }
        return changes
    }

    func purgeUploadingChanges(_ remoteChanges: [DependencyProvider.RemoteChange]) {
        storeCoordinator.coordinateWriting { changeStore in
            changeStore.moveProcessing(remoteChanges)
        }
        notifyCountChange()
    }

    func purgeUploadedChanges(_ remoteChanges: [RemoteChange]) {
        storeCoordinator.coordinateWriting { changeStore in
            changeStore.purgeProcessing(remoteChanges)
        }
        notifyCountChange()
    }

    func restoreFailedChanges(_ remoteChanges: [RemoteChange]) {
        storeCoordinator.coordinateWriting { changeStore in
            changeStore.purgeProcessing(remoteChanges)
            let conflict = UploadingFailureConflit(
                failedChanges: remoteChanges,
                pendingChanges: changeStore.pendingStoredChanges()
            )
            let solution = resolver.resolve(conflict)
            changeStore.addPending(solution.changesToRestore)
        }
        notifyCountChange()
    }

    // MARK: - DownloadLocalDataChangeStoreInterface

    func store(_ localChange: LocalChange) throws {
        try storeCoordinator.coordinateWriting { changeStore in
            let conflict = DownloadingConflit(
                newChange: localChange,
                pendingChanges: changeStore.pendingStoredChanges()
            )
            let solution = self.resolver.resolve(conflict)
            try self.localStore.perform(solution.newChangeToPersist)
            changeStore.purgePending(solution.pendingChangesToCancel)
        }
        notifyCountChange()
    }

    // MARK: - InsertLocalDataChangeStoreInterface

    func insert(_ localChange: DependencyProvider.LocalChange) throws {
        let remoteChanges = converter.remoteChanges(from: localChange)
        try storeCoordinator.coordinateWriting { changeStore in
            let conflict = InsertionConflit(
                insertedChanges: remoteChanges,
                pendingChanges: changeStore.pendingStoredChanges()
            )
            let solution = self.resolver.resolve(conflict)
            try self.localStore.perform(localChange)
            changeStore.purgePending(solution.pendingChangesToCancel)
            changeStore.addPending(remoteChanges)
        }
        notifyCountChange()
    }

    // MARK: - Private

    private func notifyCountChange() {
        var count = 0
        storeCoordinator.coordinateReading { store in
            count = store.pendingChangesCount()
        }
        changeUpdateHandler?(count)
    }
}
