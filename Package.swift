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
    ],
    dependencies: [
        .package(url: "https://github.com/metaplex-foundation/Solana.Swift.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Solita",
            dependencies: [.product(name: "Solana", package: "Solana.Swift"), "Beet"]),
        .target(
            name: "Beet",
            dependencies: [.product(name: "Solana", package: "Solana.Swift")]),
        .testTarget(
            name: "BeetTests",
            dependencies: ["Solita"],
            resources: [ .process("Resources")]),
        .testTarget(
            name: "SolitaTests",
            dependencies: ["Solita"],
            resources: [ .process("Resources")])
    ]
)
