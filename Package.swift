// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "tree-sitter-xcframework",
    platforms: [.macOS(.v10_13), .iOS(.v11)],
    products: [
        .library(
            name: "tree_sitter",
            targets: ["tree_sitter", "tree_sitter_language_resources"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "tree_sitter",
            path: "tree_sitter.xcframework"
        ),
        .target(
            name: "tree_sitter_language_resources",
            dependencies: ["tree_sitter"],
            resources: [
                .copy("LanguageResources")
            ],
            linkerSettings: [.linkedLibrary("c++")]
        )
    ]
)
