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
            name: "BeetSolana",
            targets: ["BeetSolana"]),
        .executable(
            name: "SolitaCLI",
            targets: ["SolitaCLI"]),
    ],
    dependencies: [
        .package(name: "Beet", url: "https://github.com/metaplex-foundation/beet-swift.git", from: "1.0.0"),
        .package(name: "Solana", url: "https://github.com/metaplex-foundation/Solana.Swift.git", branch: "master"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.0"),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0"),
    ],
    targets: [
        .target(
            name: "SolitaCLI",
            dependencies: ["Solita", "SwiftCLI", "PathKit",]),
        .target(
            name: "Solita",
            dependencies: ["Solana", "Beet", "PathKit", "BeetSolana"]),
        .target(
            name: "BeetSolana",
            dependencies: ["Solana", "Beet"]),
        .testTarget(
            name: "BeetSolanaTests",
            dependencies: ["Solita", "Beet"],
            resources: [ .process("Resources")]),
        .testTarget(
            name: "SolitaTests",
            dependencies: ["Solita", "Beet", "PathKit", "BeetSolana"],
            resources: [ .process("Resources")])
    ]
)
