import Foundation

class FileService {
    public static func readJsonFile<T: Decodable>(url: URL) throws -> T {
        print("Reading JSON file from \(url)")
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    public static func writeJsonFile<T: Encodable>(url: URL, data: T) throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted]
        let jsonData = try! encoder.encode(data)
        try jsonData.write(to: url)
    }
}
