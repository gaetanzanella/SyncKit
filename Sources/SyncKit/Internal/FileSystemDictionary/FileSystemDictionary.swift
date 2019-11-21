
import Foundation

class FileSystemDictionary {

    typealias Key = String

    let folderUrl: URL

    private let decoder = PropertyListDecoder()
    private let encoder = PropertyListEncoder()

    private let fileManager: FileManager

    // MARK: - Life Cycle

    init(fileManager: FileManager,
         folderURL: URL) {
        self.fileManager = fileManager
        self.folderUrl = folderURL
    }

    // MARK: - Public

    subscript<C: Codable>(key: Key) -> C? {
        set {
            if let value = newValue {
                update(value, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
        get {
            value(C.self, forKey: key)
        }
    }

    func count() -> Int {
        let contents = try? fileManager.contentsOfDirectory(
            at: folderUrl,
            includingPropertiesForKeys: nil
        )
        return (contents ?? []).count
    }

    func updateEntity(forKey key: Key, withContentAt url: URL) {
        try? fileManager.moveItem(at: url, to: valueURL(forKey: key))
    }

    func value<C: Codable>(_ entity: C.Type, forKey key: Key) -> C? {
        let url = valueURL(forKey: key)
        return value(entity, at: url)
    }

    func update<C: Codable>(_ entity: C, forKey key: Key) {
        let url = valueURL(forKey: key)
        guard let data = try? encoder.encode(entity) else { return }
        createFolderIfNeeded()
        fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
    }

    func removeValue(forKey key: Key) {
        try? fileManager.removeItem(at: valueURL(forKey: key))
    }

    func allValues<C: Codable>(_ entity: C.Type) -> [C] {
        let urls = try? fileManager.contentsOfDirectory(
            at: folderUrl,
            includingPropertiesForKeys: nil
        )
        return (urls ?? []).compactMap { value(entity, at: $0) }
    }

    func deleteAll() {
        try? fileManager.removeItem(at: folderUrl)
    }

    // MARK: - Private

    private func valueURL(forKey key: Key) -> URL {
        return folderUrl.appendingPathComponent(key)
    }

    private func createFolderIfNeeded() {
        fileManager.createIfNeededDirectory(at: folderUrl)
    }

    private func value<C: Codable>(_ entity: C.Type, at url: URL) -> C? {
        guard let data = fileManager.contents(atPath: url.path) else {
            return nil
        }
        return try? decoder.decode(entity, from: data)
    }
}

private extension FileManager {

    func createIfNeededDirectory(at url: URL) {
        try? createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
}
