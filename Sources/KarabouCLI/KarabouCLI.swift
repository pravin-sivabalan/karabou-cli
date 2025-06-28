import ArgumentParser
import Foundation
import Noora

@main
struct KarabouCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "karabou",
        abstract: "A command line tool for managing Karabiner-Elements configurations"
    )

    enum Action: String, CaseIterable, ExpressibleByArgument {
        case add
        // TODO: case remove
        // TODO: case list
    }

    @Argument(help: "The action to perform.")
    var action: Action

    // Required.
    @Option(name: .shortAndLong, help: "The key code to add.")
    var keyCode: String?

    // Required
    @Option(name: .shortAndLong, help: "The app to open when the key and modifier are pressed.")
    var appSearchQuery: String?

    // Optional with default value
    @Option(name: .shortAndLong, help: "Path to the Karabiner configuration file.")
    var configPath: String = "~/.config/karabiner/karabiner.json"

    // Optional with default value
    @Option(name: .shortAndLong, help: "The modifier to add.")
    var modifier: String = "right_command"

    func run() throws {
        let expandedPath = (configPath as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)

        switch action {
        case .add:
            if keyCode == nil || appSearchQuery == nil {
                throw ValidationError("Key code and app are required for adding a rule")
            }

            // TODO: parallelize file read and getRunningApps+search
            let runningApps = try AppsService.getRunningApps()
            let apps = SearchService.search(
                query: appSearchQuery!, items: runningApps, resultLimit: 5)
            
            var appOption: App?
            if apps.count == 0 {
                throw ValidationError("No running apps found matching the search query. We can only lookup apps that are currently running.")
            } else if apps.count == 1 {
                let app = apps[0]
                let confirmationMessage = "Found one matching app: \(app.name) (\(app.bundleIdentifier)). Do you want to select this app?"
                let confirmation = Noora().confirmationPrompt(question: confirmationMessage)
                if confirmation {
                    appOption = app
                } else {
                    throw ValidationError("App selection cancelled")
                }
            } else {
                let appOptionMap = createAppOptionMap(apps: apps)
                let selectedOption = Noora().singleChoicePrompt(
                    question: "We found \(apps.count) similar apps. Which one do you want to map?",
                    options: Array(appOptionMap.keys),
                )
                appOption = appOptionMap[selectedOption]
            }

            if appOption == nil {
                throw ValidationError("No app selected")
            }

            let app = appOption!
            print("Selected app: \(app.name)")
            print("Selected app path: \(app.appPath)")
            print("Selected app bundle identifier: \(app.bundleIdentifier)")

            let config = try FileService.readJsonFile(url: url) as KarabinerConfig

            let manager = KarabinerConfigManager(
                karabinerConfig: config, destinationRuleName: "KarabouManaged-OpenApps")
            manager.addAppOpen(keyCode: keyCode!, modifier: modifier, app: app)

            try FileService.writeJsonFile(url: url, data: manager.getKarabinerConfig())
            restartKarabiner()

            print("Rule added successfully")
        }
    }
}

func restartKarabiner() {
    let process = Process()
    process.launchPath = "/bin/bash"
    process.arguments = [
        "-c",
        "launchctl kickstart -k gui/\(getuid())/org.pqrs.karabiner.karabiner_console_user_server",
    ]
    process.launch()
    process.waitUntilExit()
}

func createAppOptionMap(apps: [App]) -> [String:App] {
    var appOptions: [String:App] = [:]
    for app in apps {
        let optionString = "\(app.name) (\(app.bundleIdentifier)): \(app.appPath)"
        appOptions[optionString] = app
    }
    return appOptions
}