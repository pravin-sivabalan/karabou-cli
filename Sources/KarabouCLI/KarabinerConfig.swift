import Foundation

struct KarabinerConfig: Codable, Equatable {
    let global: Global
    var profiles: [Profile]
}

struct Global: Codable, Equatable {
    let showInMenuBar: Bool
}

struct Profile: Codable, Equatable {
    var complexModifications: ComplexModifications
    let devices: [Device]
    let name: String
    let selected: Bool
    let virtualHIDKeyboard: VirtualHIDKeyboard?
}

struct ComplexModifications: Codable, Equatable {
    var rules: [Rule]
}

struct Rule: Codable, Equatable {
    let description: String
    var manipulators: [Manipulator]
}

struct Manipulator: Codable, Equatable {
    let description: String?
    let from: From
    let to: [To]?
    let toAfterKeyUp: [To]?
    let toIfAlone: [To]?
    let conditions: [Condition]?
    let type: String
}

struct From: Codable, Equatable {
    let keyCode: String
    let modifiers: Modifiers?
}

struct Modifiers: Codable, Equatable {
    let mandatory: [String]?
    let optional: [String]?
}

struct To: Codable, Equatable {
    let keyCode: String?
    let modifiers: [String]?
    let repeatValue: Bool?
    let setVariable: SetVariable?
    let softwareFunction: SoftwareFunction?
    
    enum CodingKeys: String, CodingKey {
        case keyCode, modifiers, setVariable, softwareFunction
        case repeatValue = "repeat"
    }
}

struct SetVariable: Codable, Equatable {
    let name: String
    let value: Int
}

struct SoftwareFunction: Codable, Equatable {
    let openApplication: OpenApplication
}

struct OpenApplication: Codable, Equatable {
    let bundleIdentifier: String
}

struct Condition: Codable, Equatable {
    let name: String
    let type: String
    let value: Int
}

struct Device: Codable, Equatable {
    let identifiers: Identifiers
    let manipulateCapsLockLed: Bool?
    let ignore: Bool?
    let mouseFlipVerticalWheel: Bool?
}

struct Identifiers: Codable, Equatable {
    let isKeyboard: Bool?
    let isPointingDevice: Bool?
    let productId: Int?
    let vendorId: Int?
}

struct VirtualHIDKeyboard: Codable, Equatable {
    let keyboardTypeV2: String
}
