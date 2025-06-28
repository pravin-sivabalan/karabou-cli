import ArgumentParser
import Foundation
import Noora

@main
struct KarabouCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "karabou",
        abstract: "A command line tool for managing Karabiner-Elements configurations",
        discussion: """
            Actions:
            • add: Add a new key mapping to open an application
            • remove: Remove an existing key mapping
            • list: List all karabou-managed key mappings
            """
    )

    enum Action: String, CaseIterable, ExpressibleByArgument {
        case add
        case remove
        case list
    }

    @Argument(help: "The action to perform.")
    var action: Action

    // Required for add and remove actions.
    @Option(name: .shortAndLong, help: "The key code to add or remove.")
    var keyCode: String?

    // Required for add action
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
                throw ValidationError(
                    "No running apps found matching the search query. We can only lookup apps that are currently running."
                )
            } else if apps.count == 1 {
                let app = apps[0]
                let confirmationMessage =
                    "Found one matching app: \(app.name) (\(app.bundleIdentifier)). Do you want to select this app?"
                let confirmation = Noora().yesOrNoChoicePrompt(
                    question: TerminalText(stringLiteral: confirmationMessage))
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
            
            do {
                try manager.addAppOpen(keyCode: keyCode!, modifier: modifier, app: app)
                
                try FileService.writeJsonFile(url: url, data: manager.getKarabinerConfig())
                restartKarabiner()
                
                print("Rule added successfully")
            } catch KarabouError.mappingAlreadyExists(let keyCode, let modifier, let existingApp) {
                let confirmationMessage = 
                    "A mapping already exists for \(keyCode) + \(modifier) → \(existingApp).\nDo you want to remove the existing mapping and add the new one?"
                let confirmation = Noora().yesOrNoChoicePrompt(
                    question: TerminalText(stringLiteral: confirmationMessage))
                
                if confirmation {
                    // User confirmed, remove existing and add new
                    manager.remove(keyCode: keyCode, modifier: modifier)
                    try manager.addAppOpen(keyCode: keyCode, modifier: modifier, app: app)
                    
                    try FileService.writeJsonFile(url: url, data: manager.getKarabinerConfig())
                    restartKarabiner()
                    
                    print("Existing mapping removed and new rule added successfully")
                } else {
                    print("Operation cancelled. Existing mapping was not changed.")
                }
            }
        case .remove:
            if keyCode == nil {
                throw ValidationError("Key code is required for removing a rule")
            }

            let config = try FileService.readJsonFile(url: url) as KarabinerConfig

            let manager = KarabinerConfigManager(
                karabinerConfig: config, destinationRuleName: "KarabouManaged-OpenApps")

            if !manager.hasManipulator(keyCode: keyCode!, modifier: modifier) {
                print("No rule found for key code '\(keyCode!)' with modifier '\(modifier)'")
                return
            }

            manager.remove(keyCode: keyCode!, modifier: modifier)

            if manager.isModified() {
                try FileService.writeJsonFile(url: url, data: manager.getKarabinerConfig())
                restartKarabiner()
                print("Rule removed successfully")
            } else {
                print("No changes made")
            }
        case .list:
            let config = try FileService.readJsonFile(url: url) as KarabinerConfig

            let manager = KarabinerConfigManager(
                karabinerConfig: config, destinationRuleName: "KarabouManaged-OpenApps")

            let mappings = manager.listMappings()

            if mappings.isEmpty {
                Noora().warning(.alert("No karabou-managed rules found"))
            } else {
                print("Found \(mappings.count) karabou-managed rule(s):")
                for mapping in mappings {
                    print("(\(mapping.mapping)) ▸ \(mapping.appName)")
                }
            }
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

func createAppOptionMap(apps: [App]) -> [String: App] {
    var appOptions: [String: App] = [:]
    for app in apps {
        let optionString = "\(app.name) (\(app.bundleIdentifier)): \(app.appPath)"
        appOptions[optionString] = app
    }
    return appOptions
}
