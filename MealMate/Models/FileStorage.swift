import Foundation

enum FileStorage {
    static private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    static func save<T: Encodable>(_ data: T, to filename: String) {
        let url = documentsPath.appendingPathComponent(filename)
        do {
            let data = try JSONEncoder().encode(data)
            try data.write(to: url)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    static func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        let url = documentsPath.appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Error loading data: \(error)")
            return nil
        }
    }
} 