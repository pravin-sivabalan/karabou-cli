import Foundation

struct App {
    let filePath: Optional<String>
    let bundleIdentifier: Optional<String>
}

struct Rule {
    let description: String
    let keyCode: String
    let app: App
}

struct KarabinerConfig {
    let rules: [Rule]
}


class KarabinerConfigService {
    let configPath: String

    init(configPath: String) {
        self.configPath = configPath
    }

    func readConfig() -> KarabinerConfig {
        let config = KarabinerConfig()
        return config
    }

    func writeConfig(config: KarabinerConfig) {
        let json = try? JSONSerialization.data(withJSONObject: config)
    }

    func addRule(rule: Rule) {
        let config = readConfig()
}


class KarabinerConfig {
    let config: [String: Any] = [
        "title": "Karabiner Config",
        "rules": [
            [
                "description": "Change Caps Lock to Control",
                "manipulators": [
                    [
                        "type": "basic",
                        "from": [
                            "key_code": "caps_lock",
                            "modifiers": [
                                "left_control"
                            ]
                        ],
                        "to": [
                            "key_code": "left_control"
                        ]
                    ]
                ]
            ]
        ]
    ]
}

func readConfig() -> [String: Any] {
    let config = KarabinerConfig()
    return config.config
}

func writeConfig(config: [String: Any]) {
    let json = try? JSONSerialization.data(withJSONObject: config)
    let jsonString = String(data: json, encoding: .utf8)
    print(jsonString)
}

func AddConfig(config: [String: Any]) {
    let config = readConfig()
    config["rules"]?.append(config)
    writeConfig(config: config)
}
