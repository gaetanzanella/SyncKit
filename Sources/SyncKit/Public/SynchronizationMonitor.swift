
public enum SynchronizationContextActivity {
    case fetchingChanges
    case uploadingChanges
    case pending
}

public class SynchronizationMonitor {

    public var activityUpdateHandler: ((SynchronizationContextActivity) -> Void)?

    public var errorUpdateHandler: ((Error) -> Void)?

    public init() {}
}
