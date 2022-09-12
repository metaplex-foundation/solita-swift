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
    ],
    targets: [
        .target(
            name: "Generated",
            dependencies: [.product(name: "Beet", package: "solita-swift"), .product(name: "BeetSolana", package: "solita-swift")]),
    ]
)