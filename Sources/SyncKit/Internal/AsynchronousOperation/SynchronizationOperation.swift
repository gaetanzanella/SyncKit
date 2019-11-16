
import Foundation

public class SynchronizationOperation: Operation {

    // MARK: - Public properties

    enum Label {
        case upload, download, insertion
    }

    let label: Label

    var startBlock: (() -> Void)?
    var finishBlock: ((Error?) -> Void)?

    // MARK: - Private properties

    @objc private class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state"]
    }

    @objc private class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }

    @objc private class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return ["state"]
    }

    private enum State: Int {
        case initialized
        case executing
        case finished

        func canTransition(to target: State) -> Bool {
            switch (self, target) {
            case (.initialized, .executing):
                return true
            case (.executing, .finished):
                return true
            default:
                return false
            }
        }
    }

    private let stateLock = NSLock()

    private var _state: State = .initialized

    private var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        set(newState) {
            willChangeValue(forKey: "state")
            stateLock.withCriticalScope {
                guard _state != .finished else { return }
                assert(_state.canTransition(to: newState), "Performing invalid state transition.")
                _state = newState
            }
            didChangeValue(forKey: "state")
        }
    }

    // MARK: - Life Cycle

    init(label: Label) {
        self.label = label
    }

    // MARK: - Operation

    public override var isExecuting: Bool {
        return state == .executing
    }

    public override var isReady: Bool {
        return state == .initialized
    }

    public override var isFinished: Bool {
        return state == .finished
    }

    public override final func main() {
        state = .executing
        if isCancelled {
            finish()
        } else {
            startBlock?()
            execute()
        }
    }

    // MARK: - SynchronizationOperation

    func execute() {
        // override
        finish()
    }

    final func finish() {
        _finish(with: nil)
    }

    final func finish(with error: Error) {
        _finish(with: error)
    }

    private func _finish(with error: Error?) {
        state = .finished
        finishBlock?(error)
    }
}
