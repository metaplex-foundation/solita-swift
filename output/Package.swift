// swift-tools-version: 5.5.0
import PackageDescription
let package = Package(
    name: "Generated",
    platforms: [.iOS(.v11), .macOS(.v10_12)],
        products: [
            .library(
                name: "Generated",
                targets: ["Generated"]),
    ],
    dependencies: [
        .package(url: "https://github.com/metaplex-foundation/solita-swift.git", branch: "main"),
        .package(name: "Beet", url: "https://github.com/metaplex-foundation/beet-swift.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Generated",
            dependencies: [
                "Beet",
                .product(name: "BeetSolana", package: "solita-swift")
            ]),
    ]
)