// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "karabou",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/tuist/Noora", .upToNextMajor(from: "0.15.0"))
    ],
    targets: [
        .executableTarget(
            name: "karabou",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Noora", package: "Noora"),
            ]),
        .testTarget(
            name: "karabouTests",
            dependencies: ["karabou"],
            resources: [
                .process("resources/input_golden_config_1.json"),
                .process("resources/output_golden_config_1.json"),
            ]),
    ]
) 
