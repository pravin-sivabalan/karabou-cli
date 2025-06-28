import ArgumentParser
import Foundation

// Sample usage:
// karabou add --key-code z --modifier right_command --app-name "Google Chrome" 
// karabou remove --key-code z --modifier right_command
// karabou list
// A custom config path can be provided with --config-path otherwise the default path is used
// karabou --config-path ~/.config/karabiner/karabiner.json add --key-code z --modifier right_command --app-name "Google Chrome" 

@main
struct KarabouCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "karabou",
        abstract: "A command line tool for managing Karabiner-Elements configurations"
    )

    @Option(name: .shortAndLong, help: "Path to the Karabiner configuration file")
    var configPath: String = "~/.config/karabiner/karabiner.json"
    
    func run() throws {
        print("Hello, world!")
    }
} 