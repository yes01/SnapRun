// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SnapRun",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "SnapRunCore",
            path: "Sources/TaskTickCore",
            resources: [
                .process("Localization")
            ]
        ),
        .executableTarget(
            name: "SnapRunApp",
            dependencies: ["SnapRunCore"],
            path: "Sources",
            exclude: ["TaskTickCore", "CLI", "Resources"]
        ),
        .executableTarget(
            name: "snaprun",
            dependencies: [
                "SnapRunCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLI"
        ),
        .testTarget(
            name: "SnapRunTests",
            dependencies: ["SnapRunApp", "SnapRunCore"],
            path: "Tests/AppTests"
        ),
        .testTarget(
            name: "CLITests",
            dependencies: ["snaprun", "SnapRunCore"],
            path: "Tests/CLITests"
        )
    ]
)
