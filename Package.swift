// swift-tools-version: 5.5.0
import PackageDescription

let package = Package(
    name: "Solita",
    platforms: [.iOS(.v11), .macOS(.v10_12)],
    products: [
        .library(
            name: "Solita",
            targets: ["Solita"]),
        .library(
            name: "Beet",
            targets: ["Beet"]),
        .library(
            name: "BeetSolana",
            targets: ["Beet"]),
    ],
    dependencies: [
        .package(url: "https://github.com/metaplex-foundation/Solana.Swift.git", branch: "master"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.7.2"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "Solita",
            dependencies: [.product(name: "StencilSwiftKit", package: "StencilSwiftKit"), .product(name: "Solana", package: "Solana.Swift"), "Beet", "PathKit", "BeetSolana"]),
        .target(
            name: "Beet",
            dependencies: [.product(name: "Solana", package: "Solana.Swift")]),
        .target(
            name: "BeetSolana",
            dependencies: [.product(name: "Solana", package: "Solana.Swift"), "Beet"]),
        .testTarget(
            name: "BeetSolanaTests",
            dependencies: ["Solita", "Beet"],
            resources: [ .process("Resources")]),
        .testTarget(
            name: "BeetTests",
            dependencies: ["Solita"],
            resources: [ .process("Resources")]),
        .testTarget(
            name: "SolitaTests",
            dependencies: ["Solita", "Beet", "PathKit", "BeetSolana"],
            resources: [ .process("Resources")])
    ]
)
