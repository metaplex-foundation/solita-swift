// swift-tools-version: 5.5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Solita",
    platforms: [.iOS(.v11), .macOS(.v10_12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Solita",
            targets: ["Solita"]),
        .library(
            name: "Beet",
            targets: ["Beet"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/metaplex-foundation/Solana.Swift.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
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
