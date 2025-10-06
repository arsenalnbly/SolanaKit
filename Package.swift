// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SolanaKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SolanaKit",
            targets: ["SolanaKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/keefertaylor/Base58Swift.git", from: "2.1.0"),
        .package(
            url: "https://github.com/arsenalnbly/Solana.Swift.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SolanaKit",
            dependencies: [
                .product(name: "Base58Swift", package: "Base58Swift"),
                .product(name: "Solana", package: "solana.swift")
            ]
        ),
        .testTarget(
            name: "SolanaKitTests",
            dependencies: ["SolanaKit"]
        ),
    ]
)
