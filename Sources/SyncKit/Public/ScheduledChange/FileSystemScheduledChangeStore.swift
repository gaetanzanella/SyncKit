
import Foundation

public class FileSystemPendingChangeStore<Change: PendingChange>: PendingChangeStore where Change: Codable {

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

    public func storedChanges() -> [Change] {
        changeDictionary.allValues(Change.self)
    }

    public func changesCount() -> Int {
        return changeDictionary.count()
    }

    public func store(_ changes: [Change]) {
        changes.forEach {
            changeDictionary[$0.storeIdentifier] = $0
        }
    }

    public func purge(_ changes: [Change]) {
        changes.forEach {
            changeDictionary.removeValue(forKey: $0.storeIdentifier)
        }
    }
}
