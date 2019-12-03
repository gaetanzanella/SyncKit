
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
            changes = store.storedChanges()
        }
        return changes
    }

    func purgeUploadedChanges(_ remoteChanges: [RemoteChange]) {
        storeCoordinator.coordinateWriting { changeStore in
            changeStore.purge(remoteChanges)
        }
        notifyCountChange()
    }

    func restoreFailedChanges(_ remoteChanges: [RemoteChange]) {
        storeCoordinator.coordinateWriting { changeStore in
            changeStore.purge(remoteChanges)
            let conflict = RemoteDataChangeUploadingFailureConflit(
                failedChanges: remoteChanges,
                pendingChanges: changeStore.storedChanges()
            )
            let solution = resolver.resolve(conflict)
            changeStore.store(solution.changesToRestore)
        }
        notifyCountChange()
    }

    // MARK: - DownloadLocalDataChangeStoreInterface

    func store(_ localChange: LocalChange) throws {
        try storeCoordinator.coordinateWriting { changeStore in
            let conflict = LocalDataChangeDownloadingConflit(
                newChange: localChange,
                pendingChanges: changeStore.storedChanges()
            )
            let solution = self.resolver.resolve(conflict)
            try self.localStore.perform(solution.newChangeToPersist)
            changeStore.purge(solution.pendingChangesToCancel)
        }
        notifyCountChange()
    }

    // MARK: - InsertLocalDataChangeStoreInterface

    func insert(_ localChange: DependencyProvider.LocalChange) throws {
        let remoteChanges = converter.remoteChanges(from: localChange)
        try storeCoordinator.coordinateWriting { changeStore in
            let conflict = RemoteDataChangeInsertionConflit(
                insertedChanges: remoteChanges,
                pendingChanges: changeStore.storedChanges()
            )
            let solution = self.resolver.resolve(conflict)
            try self.localStore.perform(localChange)
            changeStore.purge(solution.pendingChangesToCancel)
        }
        notifyCountChange()
    }

    // MARK: - Private

    private func notifyCountChange() {
        var count = 0
        storeCoordinator.coordinateReading { store in
            count = store.changesCount()
        }
        changeUpdateHandler?(count)
    }
}
