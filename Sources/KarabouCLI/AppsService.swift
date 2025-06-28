import Foundation
import AppKit


class AppsService {
    public static func getRunningApps() throws -> [App] {
        let apps = try NSWorkspace.shared.runningApplications.compactMap { app in
            guard let bundleIdentifier = app.bundleIdentifier else {
                throw KarabouError.bundleIdentifierNotFound
            }
            guard let bundleURL = app.bundleURL else {
                throw KarabouError.bundleURLNotFound
            }
            
            return App(
                name: app.localizedName ?? "Unknown",
                bundleIdentifier: bundleIdentifier,
                appPath: bundleURL.path
            )
        }
        return apps
    }
}
