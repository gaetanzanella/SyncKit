
import Foundation

public class FileSystemScheduledChangeStore: ScheduledChangeStore {

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

    public func storedChanges() -> [ScheduledChange] {
        changeDictionary.allValues(PersistentScheduledChange.self).map {
            $0.toChange()
        }
    }

    public func changesCount() -> Int {
        return changeDictionary.count()
    }

    public func store(_ changes: [ScheduledChange]) {
        changes.forEach {
            changeDictionary[$0.storingKey] = $0.toPersistentChange()
        }
    }

    public func purge(_ changes: [ScheduledChange]) {
        changes.forEach {
            changeDictionary.removeValue(forKey: $0.storingKey)
        }
    }
}
