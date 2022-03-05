// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "tree-sitter-xcframework",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "tree_sitter",
            targets: ["tree_sitter"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "tree_sitter",
            path: "tree_sitter.xcframework"
        )
    ]
)
