
class DependencyProviderProxy<DependencyProvider: SynchronizationDependencyProvider>: SynchronizationDependencyProvider {

    private let changeStore: ThreadSafeScheduledChangeStore<DependencyProvider.ChangeStore>

    private let dependencyProvider: DependencyProvider

    // MARK: - Life Cycle

    init(_ dependencyProvider: DependencyProvider) {
        self.dependencyProvider = dependencyProvider
        self.changeStore = ThreadSafeScheduledChangeStore(store: dependencyProvider.makeChangeStore())
    }

    // MARK: - SynchronizationDependencyProvider

    typealias Changeset = DependencyProvider.Changeset
    typealias ConflictResolver = DependencyProvider.ConflictResolver
    typealias ChangeStore = ThreadSafeScheduledChangeStore<DependencyProvider.ChangeStore>
    typealias PersistentStore = DependencyProvider.PersistentStore

    func makePersistentStore() -> PersistentStore {
        return dependencyProvider.makePersistentStore()
    }

    func makeConflictResolver() -> ConflictResolver {
        return dependencyProvider.makeConflictResolver()
    }

    func makeChangeStore() -> ChangeStore {
        return changeStore
    }
}
