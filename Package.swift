// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "tree-sitter-xcframework",
    platforms: [.macOS(.v10_13), .iOS(.v11)],
    products: [
        .library(
            name: "TreeSitter",
            targets: ["TreeSitter", "TreeSitterResource"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "TreeSitter",
            path: "TreeSitter.xcframework"
        ),
        .target(
            name: "TreeSitterResource",
            dependencies: ["TreeSitter"],
            resources: [
                .copy("LanguageResources")
            ],
            linkerSettings: [.linkedLibrary("c++")]
        )
    ]
)
