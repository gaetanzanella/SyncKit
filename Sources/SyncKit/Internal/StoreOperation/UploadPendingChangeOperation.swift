
import Foundation

class UploadPendingChangeOperation: AsynchronousOperation {

    let strategy: UploadPendingChangesStrategy
    let resolver: ScheduledChangeConflictResolver
    let changeStore: ScheduledChangeStore
    let persistentStore: PersistentStore
    let remoteStore: RemoteStore

    private let internalQueue = DispatchQueue(label: "upload_pending_changes_queue")

    // MARK: - Life Cycle

    init(strategy: UploadPendingChangesStrategy,
         resolver: ScheduledChangeConflictResolver,
         changeStore: ScheduledChangeStore,
         persistentStore: PersistentStore,
         remoteStore: RemoteStore) {
        self.strategy = strategy
        self.resolver = resolver
        self.changeStore = changeStore
        self.persistentStore = persistentStore
        self.remoteStore = remoteStore
    }

    // MARK: - Operation

    override func execute() {
        internalQueue.sync {
            let strategy = self.strategy
            strategy.prepare(for: changeStore.storedChanges())
            uploadChanges(
                batch: strategy.initialBatch(),
                nextBatchBlock: {
                    strategy.nextBatch(after: $0)
                },
                completion: { [weak self] result in
                    strategy.finalize()
                    self?.finish()
                }
            )
        }
    }

    // MARK: - Private

    private func uploadChanges(batch: ScheduledChangeBatch,
                               nextBatchBlock: @escaping (ScheduledChangeBatch) -> ScheduledChangeBatch?,
                               completion: @escaping (Result<Void, Error>) -> Void) {
        changeset(for: batch.changes) { [weak self] result in
            guard let self = self else { return }
            self.internalQueue.async {
                switch result {
                case let .failure(error):
                    self.resolveFailedChangeUpload(changes: batch.changes)
                    completion(.failure(error))
                case let .success(changeset):
                    self.changeStore.purge(batch.changes)
                    self.recordProviderSuccessCompletion(
                        changeset: changeset,
                        batch: batch,
                        nextBatchBlock: nextBatchBlock,
                        completion: completion
                    )
                }
            }
        }
    }

    private func changeset(for changes: [ScheduledChange],
                           completion: @escaping (Result<RecordChangeset, Error>) -> Void) {
        let recordIDsToModify = changes.filter({ $0.operation == .createOrModify }).map({ $0.recordID })
        let recordIDsToDelete = changes.filter({ $0.operation == .delete }).map({ $0.recordID })
        persistentStore.searchRecords(with: recordIDsToModify) { [weak self] result in
            guard let self = self else { return }
            self.internalQueue.async {
                completion(result.map {
                    RecordChangeset(
                        recordsToSave: $0, recordIDsToDelete: recordIDsToDelete)
                    }
                )
            }
        }
    }

    private func recordProviderSuccessCompletion(changeset: RecordChangeset,
                                                 batch: ScheduledChangeBatch,
                                                 nextBatchBlock: @escaping (ScheduledChangeBatch) -> ScheduledChangeBatch?,
                                                 completion: @escaping (Result<Void, Error>) -> Void) {
        remoteStore.perform(changeset) { [weak self] remoteResult in
            guard let self = self else { return }
            self.internalQueue.async {
                switch remoteResult {
                case let .failure(error):
                    self.resolveFailedChangeUpload(changes: batch.changes)
                    completion(.failure(error))
                case .success:
                    if let newBatch = nextBatchBlock(batch) {
                        self.uploadChanges(
                            batch: newBatch,
                            nextBatchBlock: nextBatchBlock,
                            completion: completion
                        )
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }

    private func resolveFailedChangeUpload(changes: [ScheduledChange]) {
        changeStore.purge(changes)
        let conflict = FailedChangeConflit(
            failedChangeset: changes,
            pendingChanges: changeStore.storedChanges()
        )
        let solution = resolver.resolve(conflict)
        changeStore.store(solution.changesToRestore)
    }
}
