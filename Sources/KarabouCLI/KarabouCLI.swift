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

        do {
            switch action {
            case .add:
                try handleAddAction(configUrl: url)
            case .remove:
                try handleRemoveAction(configUrl: url)
            case .list:
                try handleListAction(configUrl: url)
            }
        } catch let error as KarabouError {
            Noora().error(.alert(error.localizedDescription))
            throw ExitCode.failure
        } catch {
            Noora().error(.alert("An unexpected error occurred: \(error.localizedDescription)"))
            throw ExitCode.failure
        }
    }
    
    private func handleAddAction(configUrl: URL) throws {
        guard let keyCode = keyCode, let appSearchQuery = appSearchQuery else {
            throw ValidationError("Key code and app are required for adding a rule")
        }

        // Parallelize fetching running apps and reading configuration file using DispatchGroup
        let dispatchGroup = DispatchGroup()
        var runningApps: [App] = []
        var config: KarabinerConfig?
        var appsError: Error?
        var configError: Error?
        
        // Fetch running apps on background queue
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                runningApps = try AppsService.getRunningApps()
            } catch {
                appsError = error
            }
            dispatchGroup.leave()
        }
        
        // Read config file on another background queue  
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                config = try FileService.readJsonFile(url: configUrl) as KarabinerConfig
            } catch {
                configError = error
            }
            dispatchGroup.leave()
        }
        
        // Wait for both operations to complete
        dispatchGroup.wait()
        
        // Check for errors from parallel operations
        if let error = appsError {
            throw error
        }
        if let error = configError {
            throw error
        }
        
        guard let loadedConfig = config else {
            throw KarabouError.configurationReaderFailed(configUrl.path)
        }
        
        let apps = SearchService.search(
            query: appSearchQuery, items: runningApps, resultLimit: 5)

        let selectedApp = try selectApp(from: apps)
        
        print("Selected app: \(selectedApp.name)")
        print("Selected app path: \(selectedApp.appPath)")
        print("Selected app bundle identifier: \(selectedApp.bundleIdentifier)")

        let manager = KarabinerConfigManager(
            karabinerConfig: loadedConfig, destinationRuleName: "KarabouManaged-OpenApps")
        
        try manager.addAppOpen(keyCode: keyCode, modifier: modifier, app: selectedApp)
        try FileService.writeJsonFile(url: configUrl, data: manager.getKarabinerConfig())
        
        restartKarabiner()
        print("Rule added successfully")
    }
    
    private func handleRemoveAction(configUrl: URL) throws {
        guard let keyCode = keyCode else {
            throw ValidationError("Key code is required for removing a rule")
        }

        let config = try FileService.readJsonFile(url: configUrl) as KarabinerConfig
        let manager = KarabinerConfigManager(
            karabinerConfig: config, destinationRuleName: "KarabouManaged-OpenApps")

        if !manager.hasManipulator(keyCode: keyCode, modifier: modifier) {
            Noora().warning(.alert("No rule found for key code '\(keyCode)' with modifier '\(modifier)'"))
            return
        }

        try manager.remove(keyCode: keyCode, modifier: modifier)

        if manager.isModified() {
            try FileService.writeJsonFile(url: configUrl, data: manager.getKarabinerConfig())
            restartKarabiner()
            print("Rule removed successfully")
        } else {
            print("No changes made")
        }
    }
    
    private func handleListAction(configUrl: URL) throws {
        let config = try FileService.readJsonFile(url: configUrl) as KarabinerConfig
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
    
    private func selectApp(from apps: [App]) throws -> App {
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
                return app
            } else {
                throw ValidationError("App selection cancelled")
            }
        } else {
            let appOptionMap = createAppOptionMap(apps: apps)
            let selectedOption = Noora().singleChoicePrompt(
                question: "We found \(apps.count) similar apps. Which one do you want to map?",
                options: Array(appOptionMap.keys),
            )
            guard let selectedApp = appOptionMap[selectedOption] else {
                throw ValidationError("No app selected")
            }
            return selectedApp
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
