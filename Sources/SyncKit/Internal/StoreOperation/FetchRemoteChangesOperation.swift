
import Foundation

class FetchRemoteChangesOperation: AsynchronousOperation {

    let strategy: DownloadRemoteChangesStrategy
    let changeStore: ScheduledChangeStore
    let conflictResolver: ScheduledChangeConflictResolver
    let persistentStore: PersistentStore
    let remoteStore: RemoteStore

    private let internalQueue = DispatchQueue(label: "fetch_remote_changes_queue")

    init(strategy: DownloadRemoteChangesStrategy,
         changeStore: ScheduledChangeStore,
         conflictResolver: ScheduledChangeConflictResolver,
         persistentStore: PersistentStore,
         remoteStore: RemoteStore) {
        self.strategy = strategy
        self.changeStore = changeStore
        self.conflictResolver = conflictResolver
        self.persistentStore = persistentStore
        self.remoteStore = remoteStore
    }

    // MARK: - AsynchronousOperation

    override func execute() {
        internalQueue.sync {
            let strategy = self.strategy
            strategy.prepare()
            downloadChanges(
                named: strategy.initialDownloadedRecordNames(),
                nextNamesBlock: {
                    strategy.nextDownloadedRecordNames(after: $0)
                },
                completion: { [weak self] result in
                    strategy.finalize()
                    self?.finish()
                }
            )
        }
    }

    // MARK: - Private

     private func downloadChanges(named names: [Record.Name],
                                 nextNamesBlock: @escaping ([Record.Name]) -> [Record.Name]?,
                                 completion: @escaping (Result<Void, Error>) -> Void) {
        remoteStore.fetchChanges(forRecordsNamed: names) { [weak self] result in
            guard let self = self else { return }
            self.internalQueue.async {
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .success(changeset):
                    self.fetchChangesSuccessCompletion(
                        changeset: changeset,
                        names: names,
                        nextNamesBlock: nextNamesBlock,
                        completion: completion
                    )
                }
            }
        }
    }

    private func fetchChangesSuccessCompletion(changeset: RecordChangeset,
                                               names: [Record.Name],
                                               nextNamesBlock: @escaping ([Record.Name]) -> [Record.Name]?,
                                               completion: @escaping (Result<Void, Error>) -> Void) {
        persistDownloadedRecords(changeset: changeset) { [weak self] result in
            guard let self = self else { return }
            self.internalQueue.async {
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    if let nextNames = nextNamesBlock(names) {
                        self.downloadChanges(
                            named: nextNames,
                            nextNamesBlock: nextNamesBlock,
                            completion: completion
                        )
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }

    private func persistDownloadedRecords(changeset: RecordChangeset,
                                          completion: @escaping (Result<Void, Error>) -> Void) {
        let conflict = FetchedChangeConflit(
            newChangeset: changeset,
            pendingChanges: changeStore.storedChanges()
        )
        let solution = conflictResolver.resolve(conflict)
        persistentStore.perform(solution.newChangesToPersist) { [weak self] result in
            self?.internalQueue.async {
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    self?.changeStore.purge(solution.pendingChangesToCancel)
                    completion(.success(()))
                }
            }
        }
    }
}
