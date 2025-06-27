import ArgumentParser

@main
struct Karabou: ParsableCommand {
  @Option(commandName: "add", help: "Add a new command")
  var add: Bool = false

  @Option(commandName: "remove", help: "Remove a command")
  var remove: Bool = false

  @Argument(key: "key", help: "The key code to add or remove")
  var key: String?

  @Argument(appName: "app", help: "The name of the app to open")
  var appName: String?

  mutating func run() throws {
    if add {
      let addAppOpen = AddAppOpen(keyCode: key, appName: appName)
      addAppOpen.run()
    } else if remove {
      let removeAppOpen = RemoveAppOpen(keyCode: key)
      removeAppOpen.run()
    }
  }
}