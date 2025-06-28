import Foundation

class FileService {
    public static func readJsonFile<T: Decodable>(url: URL) throws -> T {
        print("Reading JSON file from \(url)")
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw KarabouError.fileNotFound(url.path)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw KarabouError.invalidJsonFormat(decodingError.localizedDescription)
        } catch {
            throw KarabouError.configurationReaderFailed(url.path)
        }
    }

    public static func writeJsonFile<T: Encodable>(url: URL, data: T) throws {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.outputFormatting = [.prettyPrinted]
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: url)
        } catch {
            throw KarabouError.configurationWriterFailed(url.path)
        }
    }
}
