
import Foundation

public class FileSystemScheduledChangeStore<ID: ManagedRecordID>: ScheduledChangeStore where ID: Codable {

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

    public func storedChanges() -> [ScheduledChange<ID>] {
        changeDictionary.allValues(PersistentScheduledChange<ID>.self).map {
            $0.toChange()
        }
    }

    public func changesCount() -> Int {
        return changeDictionary.count()
    }

    public func store(_ changes: [ScheduledChange<ID>]) {
        changes.forEach {
            changeDictionary[$0.storingKey] = $0.toPersistentChange()
        }
    }

    public func purge(_ changes: [ScheduledChange<ID>]) {
        changes.forEach {
            changeDictionary.removeValue(forKey: $0.storingKey)
        }
    }
}
