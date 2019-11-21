
import Foundation

public enum SynchronizationContextActivity {
    case fetchingChanges
    case uploadingChanges
    case pending
}

public class SynchronizationMonitor {

    // MARK: - Public properties

    public var activityUpdateHandler: ((SynchronizationContextActivity) -> Void)?

    public var errorHandler: ((Error) -> Void)?

    public var pendingChangesCountUpdateHandler: ((Int) -> Void)?

    // MARK: - Private properties

    private let notificationQueue: DispatchQueue

    // MARK: - Life Cycle

    public init(notificationQueue: DispatchQueue = .main) {
        self.notificationQueue = notificationQueue
    }

    // MARK: - Internal

    func notify(_ error: Error) {
        guard let handler = errorHandler else { return }
        notificationQueue.async {
            handler(error)
        }
    }

    func notifyPendingChangesCountUpdate(_ count: Int) {
        guard let handler = pendingChangesCountUpdateHandler else { return }
        notificationQueue.async {
            handler(count)
        }
    }

    func notify(_ activity: SynchronizationContextActivity) {
        guard let handler = activityUpdateHandler else { return }
        notificationQueue.async {
            handler(activity)
        }
    }
}
