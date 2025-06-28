enum KarabouError: Error {
    case bundleIdentifierNotFound
    case bundleURLNotFound
    case configurationReaderFailed
    case configurationWriterFailed
    case mappingAlreadyExists(keyCode: String, modifier: String, existingApp: String)
}
