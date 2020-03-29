
import Foundation

public class FileSystemRemoteDataChangeQueue<RemoteChange: RemoteDataChange>: RemoteDataChangeQueue where RemoteChange: Codable, RemoteChange.ID: CustomStringConvertible {

    // MARK: - Public properties

    var folder: URL {
        pendingDictionary.folderUrl
    }

    // MARK: - Private properties

    private let pendingDictionary: FileSystemDictionary
    private let processingDictionary: FileSystemDictionary

    // MARK: - Life Cycle

    public init(fileManager: FileManager = .default,
                folder: URL) {
        self.pendingDictionary = FileSystemDictionary(
            fileManager: fileManager,
            folderURL: folder.appendingPathComponent("Pending")
        )
        self.processingDictionary = FileSystemDictionary(
            fileManager: fileManager,
            folderURL: folder.appendingPathComponent("Processing")
        )
    }

    // MARK: - FileSystemRemoteDataChangeQueue

    public func changesCount(in state: RemoteDataChangeState) -> Int {
        dictionary(for: state).count()
    }

    public func changes(in state: RemoteDataChangeState) -> [RemoteChange] {
        dictionary(for: state).allValues(RemoteChange.self)
    }

    public func add(_ changes: [RemoteChange], for state: RemoteDataChangeState) {
        changes.forEach {
            dictionary(for: state)[String(describing: $0.id)] = $0
        }
    }

    public func remove(_ changes: [RemoteChange], for state: RemoteDataChangeState) {
        changes.forEach {
            dictionary(for: state).removeValue(forKey: String(describing: $0.id))
        }
    }

    public func purgeAllChanges() {
        pendingDictionary.deleteAll()
        processingDictionary.deleteAll()
    }

    // MARK: - Private

    private func dictionary(for state: RemoteDataChangeState) -> FileSystemDictionary {
        switch state {
        case .pending:
            return pendingDictionary
        case .processing:
            return processingDictionary
        }
    }
}
