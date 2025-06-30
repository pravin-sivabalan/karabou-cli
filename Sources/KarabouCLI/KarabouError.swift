import Foundation

enum KarabouError: Error, LocalizedError {
    case bundleIdentifierNotFound
    case bundleURLNotFound
    case configurationReaderFailed(String)
    case configurationWriterFailed(String)
    case unsupportedModifier(String)
    case duplicateKeyMapping(String, String)
    case keyMappingNotFound(String, String)
    case fileNotFound(String)
    case invalidJsonFormat(String)
    case mappingAlreadyExists(keyCode: String, modifier: String, existingApp: String)
    case noAppsFound
    case appSelectionCancelled
    case noAppSelected
    case scanningAppsFailed(String)


    var errorDescription: String? {
        switch self {
        case .bundleIdentifierNotFound:
            return "Unable to find bundle identifier for the application"
        case .bundleURLNotFound:
            return "Unable to find bundle URL for the application"
        case .configurationReaderFailed(let path):
            return "Failed to read configuration file at: \(path)"
        case .configurationWriterFailed(let path):
            return "Failed to write configuration file at: \(path)"
        case .unsupportedModifier(let modifier):
            return
                "Modifier '\(modifier)' is not supported. Only 'right_command' is currently supported"
        case .duplicateKeyMapping(let keyCode, let modifier):
            return
                "Key mapping for '\(keyCode) + \(modifier)' already exists. Please remove the existing mapping first"
        case .keyMappingNotFound(let keyCode, let modifier):
            return "No key mapping found for '\(keyCode) + \(modifier)'"
        case .fileNotFound(let path):
            return "File not found at: \(path)"
        case .invalidJsonFormat(let details):
            return "Invalid JSON format: \(details)"
        case .mappingAlreadyExists(let keyCode, let modifier, let existingApp):
            return
                "Key mapping for '\(keyCode) + \(modifier)' already exists for app '\(existingApp)'. Please remove the existing mapping first"
        case .noAppsFound:
            return
                "No apps found matching the search query. Try to open the app you're trying to map, this should hopefully help us find the app."
        case .appSelectionCancelled:
            return "App selection cancelled"
        case .noAppSelected:
            return "No app selected"
        case .scanningAppsFailed(let path):
            return "Failed to scan apps at: \(path)"
        }
    }
}
