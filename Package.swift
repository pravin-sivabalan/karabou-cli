// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "karabou-cli",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "karabou-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "karabou-cliTests",
            dependencies: ["karabou-cli"],
            resources: [
                .process("resources/input_golden_config_1.json"),
                .process("resources/output_golden_config_1.json"),
            ]),
    ]
) 
