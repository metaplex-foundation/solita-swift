import Foundation
import PathKit
import CommonCrypto
import XCTest

let package =
"""
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
"""

func createHash(s data: Data) -> String {
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash).toHexString()
}

struct AnalyzedCode {
    let swift: String
    let errors: [String]
    let warnings: [String]
}

struct BuildedLogCode {
    let swift: String
    let output: [String]
}

func shell(command: String) throws -> [String] {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    if #available(macOS 10.13, *) {
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    } else {
        task.launchPath = "/bin/zsh"
    }
    task.standardInput = nil
    
    if #available(macOS 10.13, *) {
        try task.run()
    } else {
        task.launch()
    }
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    task.waitUntilExit()
    return output.split(separator: "\n").map{ "\($0)"}
}

func analyzeCode(swift: String, logBuild: Bool = false) -> BuildedLogCode {
    let hash = createHash(s: (swift + UUID().uuidString).data(using: .utf8)!)
    let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory())
    let tempDir = Path(temporaryFolderURL.path) + Path("\(hash)")
    let sourcesPath = tempDir + Path("Sources/Generated")
    let filePath = sourcesPath + Path("\(hash).swift")
    let packagePath = tempDir + Path("Package.swift")
    if !filePath.exists {
        try! sourcesPath.mkpath()
        FileManager.default.createFile(atPath: filePath.string, contents: nil, attributes: nil)
    }
    print("Build Location: \(tempDir.string)" )
    try! swift.write(to: filePath.url, atomically: true, encoding: String.Encoding.utf8)
    try! package.write(to: packagePath.url, atomically: true, encoding: String.Encoding.utf8)
    let output = try! shell(command: "cd \(tempDir.string); swift build")
    if logBuild { print(output) }
    return BuildedLogCode(swift: swift, output: output)
}


func verifySyntacticCorrectness(swift: String) {
    let hash = createHash(s: (swift + UUID().uuidString).data(using: .utf8)!)
    let filename = "\(hash).swift"
    let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory())
    let filePath = Path(temporaryFolderURL.path) + Path(filename)
    if !FileManager.default.fileExists(atPath: filePath.string) {
        FileManager.default.createFile(atPath: filePath.string, contents: nil, attributes: nil)
    }
    try! swift.write(to: filePath.url, atomically: true, encoding: String.Encoding.utf8)
    
    let output = try! shell(command: "/opt/homebrew/bin/swiftlint lint \(filePath.string)")
    let analizedCode = AnalyzedCode(swift: swift, errors: output.filter{ $0.contains("error")}, warnings: output.filter{ $0.contains("warning") })
    
    if (analizedCode.errors.count > 0) {
        for error in analizedCode.errors {
            print(error)
        }
        XCTAssert(analizedCode.errors.isEmpty)
    }
}
