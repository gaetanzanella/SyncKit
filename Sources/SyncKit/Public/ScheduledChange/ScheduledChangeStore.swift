
public enum ScheduledChangeState {
    case pending, processing
}

public protocol ScheduledChangeStore {
    func changes(in state: ScheduledChangeState) -> [ScheduledChange]
    func mark(_ changes: [ScheduledChange], as state: ScheduledChangeState)
    func purge(_ changes: [ScheduledChange])
}
