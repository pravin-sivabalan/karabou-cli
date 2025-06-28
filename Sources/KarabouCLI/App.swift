struct App : LosslessStringConvertible {
    let name: String
    let bundleIdentifier: String
    let appPath: String
    public static let DELIMITER = "***"

    var description: String {
        return "\(name)\(App.DELIMITER)\(appPath)\(App.DELIMITER)\(bundleIdentifier)"
    }

    init(name: String, bundleIdentifier: String, appPath: String) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.appPath = appPath
    }
    
    init?(_ description: String) {
        let components = description.components(separatedBy: App.DELIMITER)
        guard components.count >= 3 else { return nil }
        
        self.name = components[0]
        self.appPath = components[1]
        self.bundleIdentifier = components[2]
    }
}
