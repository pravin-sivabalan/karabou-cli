// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "karabou",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/tuist/Noora", .upToNextMajor(from: "0.15.0"))
    ],
    targets: [
        .executableTarget(
            name: "KarabouCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Noora", package: "Noora"),
            ]),
        .testTarget(
            name: "karabou-cliTests",
            dependencies: ["KarabouCLI"],
            resources: [
                .process("resources"),
            ]),
    ]
) 
