
import Foundation

public class FileSystemRemoteDataChangeStore<RemoteChange: RemoteDataChange>: RemoteDataChangeStore where RemoteChange: Codable {

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

    public func storedChanges() -> [RemoteChange] {
        changeDictionary.allValues(RemoteChange.self)
    }

    public func changesCount() -> Int {
        return changeDictionary.count()
    }

    public func store(_ changes: [RemoteChange]) {
        changes.forEach {
            changeDictionary[$0.storeIdentifier] = $0
        }
    }

    public func purge(_ changes: [RemoteChange]) {
        changes.forEach {
            changeDictionary.removeValue(forKey: $0.storeIdentifier)
        }
    }
}
