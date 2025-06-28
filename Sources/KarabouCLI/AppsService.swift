import Foundation
import AppKit


class AppsService {
    public static func getRunningApps() throws -> [App] {
        let apps: [App] = NSWorkspace.shared.runningApplications.compactMap { app in
            guard let bundleIdentifier = app.bundleIdentifier else {
                return nil
            }
            guard let bundleURL = app.bundleURL else {
                return nil
            }

            if bundleURL.path.hasPrefix("/System") {
                return nil
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
