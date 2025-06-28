import Foundation

class KarabinerConfigManager {
    private var karabinerConfig: KarabinerConfig
    private var _isModified: Bool = false
    private let destinationRuleName: String
    private var mappedKeyAndModifier: Set<String> = Set<String>()  // make this an app of keycode to app
    private var mappings: [String: String] = [:]

    init(karabinerConfig: KarabinerConfig, destinationRuleName: String) {
        self.karabinerConfig = karabinerConfig
        self.destinationRuleName = destinationRuleName

        var keysWithDuplicateMappings: [String] = []
        for profile in karabinerConfig.profiles {
            for rule in profile.complexModifications.rules {
                for manipulator in rule.manipulators {
                    let keyCode = manipulator.from.keyCode
                    let modifier = manipulator.from.modifiers?.mandatory?.first ?? ""
                    let hash = encodeKeyAndModifier(keyCode: keyCode, modifier: modifier)

                    if mappings.contains(where: { $0.key == hash }) {
                        keysWithDuplicateMappings.append(hash)
                    }

                    if let app = manipulator.to?.first?.softwareFunction?.openApplication {
                        mappings[hash] = app.bundleIdentifier
                    }
                }
            }
        }

        if keysWithDuplicateMappings.count > 0 {
            print("Warning: KeyCode \(keysWithDuplicateMappings) have duplicate mappings")
        }
    }

    public func addAppOpen(keyCode: String, modifier: String, app: App) {
        if modifier != "right_command" {
            // TODO: throw an error
            print("Warning: Modifier \(modifier) not supported")
            return
        }

        let hash = encodeKeyAndModifier(keyCode: keyCode, modifier: modifier)
        guard !mappedKeyAndModifier.contains(hash) else {
            // TODO: throw an error, caller should remove first
            return
        }

        var newRules = karabinerConfig.profiles.first?.complexModifications.rules ?? []
        let managedManipulatorIndex = newRules.firstIndex { rule in
            rule.description == destinationRuleName
        }
        var managedManipulators: [Manipulator] = []
        if let managedManipulatorIndex = managedManipulatorIndex {
            managedManipulators = newRules[managedManipulatorIndex].manipulators
            newRules.remove(at: managedManipulatorIndex)
        }

        let newManipulator = createManipulator(keyCode: keyCode, modifier: modifier, app: app)
        let newManipulators = managedManipulators + [newManipulator]

        newRules.append(
            Rule(
                description: destinationRuleName,
                manipulators: newManipulators))

        var profile = karabinerConfig.profiles.first
        profile?.complexModifications.rules = newRules
        karabinerConfig.profiles = [profile!]

        mappedKeyAndModifier.insert(hash)
        _isModified = true
    }

    public func remove(keyCode: String, modifier: String) {
        if modifier != "right_command" {
            // TODO: throw an error
            print("Warning: Modifier \(modifier) not supported")
            return
        }

        let hash = encodeKeyAndModifier(keyCode: keyCode, modifier: modifier)
        guard mappedKeyAndModifier.contains(hash) else {
            print("Warning: KeyCode \(keyCode) with modifier \(modifier) not mapped")
            // TODO: throw an error, remove should be handled by the caller
            return
        }

        var newRules = karabinerConfig.profiles.first?.complexModifications.rules ?? []
        
        // Remove the manipulator from the managed rule
        for i in 0..<newRules.count {
            if newRules[i].description == destinationRuleName {
                newRules[i].manipulators.removeAll { manipulator in
                    manipulator.from.keyCode == keyCode
                        && manipulator.from.modifiers?.mandatory?.contains(modifier) == true
                }
                // If no manipulators left, remove the entire rule
                if newRules[i].manipulators.isEmpty {
                    newRules.remove(at: i)
                }
                break
            }
        }

        var profile = karabinerConfig.profiles.first
        profile?.complexModifications.rules = newRules
        karabinerConfig.profiles = [profile!]

        mappedKeyAndModifier.remove(hash)
        _isModified = true
    }

    public func listMappings() -> [(mapping: String, appName: String)] {
        return mappings.map { (key, value) in
            return (mapping: key, appName: value)
        }
    }

    public func hasManipulator(keyCode: String, modifier: String) -> Bool {
        return mappedKeyAndModifier.contains(encodeKeyAndModifier(keyCode: keyCode, modifier: modifier))
    }

    public func getKarabinerConfig() -> KarabinerConfig {
        return karabinerConfig
    }

    public func isModified() -> Bool {
        return _isModified
    }

    private func createManipulator(keyCode: String, modifier: String, app: App) -> Manipulator {
        // for some reason I have optional: caps_lock in the modifiers, but that shouldn't be needed.
        // leaving a note in case that causes issues.
        return Manipulator(
            description: nil,
            from: From(
                keyCode: keyCode, modifiers: Modifiers(mandatory: [modifier], optional: nil)),
            to: [
                To(
                    keyCode: nil,
                    modifiers: nil,
                    repeatValue: nil,
                    setVariable: nil,
                    softwareFunction: SoftwareFunction(
                        openApplication: OpenApplication(bundleIdentifier: app.bundleIdentifier)))
            ],
            toAfterKeyUp: nil,
            toIfAlone: nil,
            conditions: nil,
            type: "basic")
    }

    private func encodeKeyAndModifier(keyCode: String, modifier: String) -> String {
        return "\(keyCode) + \(modifier)"
    }
}
