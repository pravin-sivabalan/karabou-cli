import Foundation

class KarabinerConfigManager {
    private var karabinerConfig: KarabinerConfig
    private var _isModified: Bool = false
    private let destinationRuleName: String
    private var mappedKeys: Set<String> = Set<String>() // make this an app of keycode to app

    init(karabinerConfig: KarabinerConfig, destinationRuleName: String) {
        self.karabinerConfig = karabinerConfig
        self.destinationRuleName = destinationRuleName

        for profile in karabinerConfig.profiles {
            for rule in profile.complexModifications.rules {
                for manipulator in rule.manipulators {
                    if mappedKeys.contains(manipulator.from.keyCode) {
                        print("Warning: KeyCode \(manipulator.from.keyCode) already mapped")
                    } else {
                        mappedKeys.insert(manipulator.from.keyCode)
                    } 
                }
            }
        }

        if mappedKeys.count > 0 {
            print("Warning: KeyCode \(mappedKeys) already mapped")
            return
        }
    }

    public func addAppOpen(keyCode: String, modifier: String, app: App) {
        if modifier != "right_command" {
            // TODO: throw an error
            print("Warning: Modifier \(modifier) not supported")
            return
        }

        guard mappedKeys.contains(keyCode) else {
            // TODO: throw an error, caller should remove first
            return
        }

        var newRules = karabinerConfig.profiles.first?.complexModifications.rules ?? []
        let managedManipulators =
            newRules.filter { rule in
                rule.description == destinationRuleName
            }.first?.manipulators ?? []
        let newManipulator = createManipulator(keyCode: keyCode, modifier: modifier, app: app)
        let newManipulators = managedManipulators + [newManipulator]

        newRules.append(
            Rule(
                description: destinationRuleName,
                manipulators: newManipulators))

        var profile = karabinerConfig.profiles.first
        profile?.complexModifications.rules = newRules
        karabinerConfig.profiles = [profile!]

        mappedKeys.insert(keyCode)
        _isModified = true
    }

    public func remove(keyCode: String, modifier: String) {
        if modifier != "right_command" {
            // TODO: throw an error
            print("Warning: Modifier \(modifier) not supported")
            return
        }

        guard !mappedKeys.contains(keyCode) else {
            print("Warning: KeyCode \(keyCode) not mapped")
            // TODO: throw an error, remove should be handled by the caller
            return
        }

        var newRules = karabinerConfig.profiles.first?.complexModifications.rules ?? []
        let indexOfManipulatorToRemove = newRules.firstIndex { rule in
            rule.manipulators.contains { manipulator in
                manipulator.from.keyCode == keyCode
                    && manipulator.from.modifiers?.mandatory?.contains(modifier) == true
            }
        }
        if let indexOfManipulatorToRemove = indexOfManipulatorToRemove {
            newRules[indexOfManipulatorToRemove].manipulators.removeAll { manipulator in
                manipulator.from.keyCode == keyCode
                    && manipulator.from.modifiers?.mandatory?.contains(modifier) == true
            }
        }

        var profile = karabinerConfig.profiles.first
        profile?.complexModifications.rules = newRules
        karabinerConfig.profiles = [profile!]

        mappedKeys.remove(keyCode)
        _isModified = true
    }

    // should still check across rules to make sure there are not duplicate mappings
    // if there are throw an error.
    public func hasManipulator(keyCode: String) -> Bool {
        return mappedKeys.contains(keyCode)
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

}
