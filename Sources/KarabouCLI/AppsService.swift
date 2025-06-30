import Foundation

#if canImport(AppKit)
    import AppKit
#endif

class AppsService {
    private static var hardcodedApps: [App] = [
        // Messages seems to be a special case, for some reason it doesn't have a bundle URL.
        App(
            name: "Messages", bundleIdentifier: "com.apple.MobileSMS",
            appPath: "/Applications/Messages.app")
    ]

    public static func getApps() throws -> [App] {
        #if canImport(AppKit)
            return mergeAppLists(appLists: getRunningApps(), getInstalledApps(), hardcodedApps)
        #else
            // For non-macOS platforms, return empty array for testing
            return []
        #endif
    }

    private static func mergeAppLists(appLists: [App]...) -> [App] {
        var allApps: [App] = []
        var existingBundleIds = Set<String>()
        for apps in appLists {
            for app in apps {
                if !existingBundleIds.contains(app.bundleIdentifier) {
                    allApps.append(app)
                    existingBundleIds.insert(app.bundleIdentifier)
                }
            }
        }
        return allApps
    }

    private static func getRunningApps() -> [App] {
        #if canImport(AppKit)
            return NSWorkspace.shared.runningApplications.compactMap { app in
                guard let bundleIdentifier = app.bundleIdentifier else {
                    return nil
                }

                guard let bundleURL = app.bundleURL else {
                    return nil
                }

                if !bundleURL.path.hasPrefix("/Applications") {
                    return nil
                }

                if !bundleURL.path.hasSuffix(".app") {
                    return nil
                }

                let appName = app.localizedName ?? "Unknown"

                guard isBackgroundApp(name: appName, bundleIdentifier: bundleIdentifier) else {
                    return nil
                }

                return App(
                    name: appName,
                    bundleIdentifier: bundleIdentifier,
                    appPath: bundleURL.path
                )
            }
        #else
            return []
        #endif
    }

    private static func getInstalledApps() -> [App] {
        var installedApps: [App] = []

        // Scan /Applications folder
        let applicationsPath = "/Applications"
        if let apps = scanDirectoryForApps(at: applicationsPath) {
            installedApps.append(contentsOf: apps)
        }

        let userApplicationsPath = (NSHomeDirectory() as NSString).appendingPathComponent(
            "Applications")
        if let userApps = scanDirectoryForApps(at: userApplicationsPath) {
            installedApps.append(contentsOf: userApps)
        }

        let userChromeAppsPath = (userApplicationsPath as NSString).appendingPathComponent(
            "Chrome Apps.localized")
        if let userChromeApps = scanDirectoryForApps(at: userChromeAppsPath) {
            installedApps.append(contentsOf: userChromeApps)
        }

        return installedApps
    }

    private static func scanDirectoryForApps(at path: String) -> [App]? {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: path) else {
            print("File does not exist at path: \(path)")
            return nil
        }

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            var apps: [App] = []

            for item in contents {
                let fullPath = (path as NSString).appendingPathComponent(item)

                // Check if it's a .app bundle
                if item.hasSuffix(".app") {
                    if let app = createAppFromBundle(at: fullPath) {
                        apps.append(app)
                    }
                }
            }

            return apps
        } catch {
            print("Error scanning directory \(path): \(error)")
            return nil
        }
    }

    private static func createAppFromBundle(at path: String) -> App? {
        let bundle = Bundle(path: path)
        guard let bundle = bundle else {
            return nil
        }
        guard let bundleIdentifier = bundle.bundleIdentifier else {
            return nil
        }

        // Try to infer app name from bundle info dictionary
        let appName =
            bundle.infoDictionary?["CFBundleName"] as? String ?? bundle.infoDictionary?[
                "CFBundleDisplayName"] as? String
            ?? (path as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: "")

        guard isBackgroundApp(name: appName, bundleIdentifier: bundleIdentifier) else {
            return nil
        }

        return App(
            name: appName,
            bundleIdentifier: bundleIdentifier,
            appPath: path
        )
    }

    private static func isBackgroundApp(name: String, bundleIdentifier: String) -> Bool {
        // Filter out apps with helper-like bundle identifiers
        if bundleIdentifier.contains(".helper") || bundleIdentifier.contains(".background")
            || bundleIdentifier.contains(".agent") || bundleIdentifier.contains(".daemon")
            || bundleIdentifier.contains(".service") || bundleIdentifier.contains(".plugin")
            || bundleIdentifier.contains(".extension")
        {
            return false
        }

        // Filter out common background process patterns in app name
        let lowercasedName = name.lowercased()
        if lowercasedName.contains("helper") || lowercasedName.contains("background")
            || lowercasedName.contains("agent") || lowercasedName.contains("daemon")
            || lowercasedName.contains("service") || lowercasedName.contains("plugin")
            || lowercasedName.contains("extension")
        {
            return false
        }

        return true
    }
}
