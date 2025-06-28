import Foundation
#if canImport(AppKit)
import AppKit
#endif

class AppsService {
    public static func getRunningApps() throws -> [App] {
        #if canImport(AppKit)
        let apps: [App] = NSWorkspace.shared.runningApplications.compactMap { app in
            guard let bundleIdentifier = app.bundleIdentifier else {
                return nil
            }
            guard let bundleURL = app.bundleURL else {
                return nil
            }

            // Filter out system apps
            if bundleURL.path.hasPrefix("/System") {
                return nil
            }

            // Filter out helper applications and background processes
            if bundleURL.path.contains(".app/Contents/") && !bundleURL.path.hasSuffix(".app") {
                return nil
            }
            
            // Filter out apps with helper-like bundle identifiers
            if bundleIdentifier.contains(".helper") || 
               bundleIdentifier.contains(".background") ||
               bundleIdentifier.contains(".agent") ||
               bundleIdentifier.contains(".daemon") ||
               bundleIdentifier.contains(".service") ||
               bundleIdentifier.contains(".plugin") ||
               bundleIdentifier.contains(".extension") {
                return nil
            }

            // Filter out common background process patterns
            let appName = app.localizedName ?? "Unknown"
            if appName.lowercased().contains("helper") ||
               appName.lowercased().contains("background") ||
               appName.lowercased().contains("agent") ||
               appName.lowercased().contains("daemon") ||
               appName.lowercased().contains("service") {
                return nil
            }

            return App(
                name: appName,
                bundleIdentifier: bundleIdentifier,
                appPath: bundleURL.path
            )
        }
        return apps
        #else
        // For non-macOS platforms, return empty array for testing
        return []
        #endif
    }
}
