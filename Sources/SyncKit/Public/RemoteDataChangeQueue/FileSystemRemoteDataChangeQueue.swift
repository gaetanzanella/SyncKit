
import Foundation

public class FileSystemRemoteDataChangeQueue<RemoteChange: RemoteDataChange>: RemoteDataChangeQueue where RemoteChange: Codable {

    // MARK: - Public properties

    var folder: URL {
        changeDictionary.folderUrl
    }

    // MARK: - Private properties

    private let changeDictionary: FileSystemDictionary

    // MARK: - Life Cycle

    public init(fileManager: FileManager = .default,
                folder: URL) {
        self.changeDictionary = FileSystemDictionary(
            fileManager: fileManager,
            folderURL: folder.appendingPathComponent("ScheduledChange")
        )
    }

    // MARK: - Public

    func purgeAllChanges() {
        changeDictionary.deleteAll()
    }

    // MARK: - ScheduledChangeStore

    public func changes() -> [RemoteChange] {
        changeDictionary.allValues(RemoteChange.self)
    }

    public func changesCount() -> Int {
        return changeDictionary.count()
    }

    public func add(_ changes: [RemoteChange]) {
        changes.forEach {
            changeDictionary[$0.storeIdentifier] = $0
        }
    }

    public func remove(_ changes: [RemoteChange]) {
        changes.forEach {
            changeDictionary.removeValue(forKey: $0.storeIdentifier)
        }
    }
}
