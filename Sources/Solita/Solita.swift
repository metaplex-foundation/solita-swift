import PathKit
import SwiftCLI

public class Solita {
    public let idl: Idl
    public var paths: Paths?
    public var projectName: String
    public var programId: String?
    private let hasInstructions: Bool
    private let accountsHaveImplicitDiscriminator: Bool
    private let typeAliases: Dictionary<String, PrimitiveTypeKey>
    private let serializers: CustomSerializers
    private let prependGeneratedWarning: Bool
    public init(idl: Idl,
                projectName: String="Generated",
                prependGeneratedWarning: Bool=true,
                accountsHaveImplicitDiscriminator: Bool=false,
                typeAliases: Dictionary<String, PrimitiveTypeKey>=[:],
                serializers: CustomSerializers?=nil,
                programId: String?=nil
    ) {
        self.idl = idl
        self.projectName = projectName
        self.hasInstructions = idl.instructions.count > 0
        self.typeAliases = typeAliases
        self.prependGeneratedWarning = prependGeneratedWarning
        self.accountsHaveImplicitDiscriminator = accountsHaveImplicitDiscriminator
        self.serializers = serializers ?? CustomSerializers.empty()
        self.programId = programId
    }
    
    
    // -----------------
    // Extract
    // -----------------
    private func accountFilesByType() -> Dictionary<String, String> {
        var accountsFiles: Dictionary<String, String> = [:]
        
        self.idl.accounts?.forEach {
            accountsFiles[$0.name] = self.paths!.accountFile(name: $0.name)
        }
        return accountsFiles
    }
    
    private func customFilesByType() -> [String: String] {
        var customFilesByType: Dictionary<String, String> = [:]
        self.idl.types?.forEach {
            customFilesByType[$0.name] = self.paths!.typeFile(name: $0.name)
        }
        return customFilesByType
    }
    
    private func resolveFieldType(_ typeName: String) -> IdlType? {
        // Todo: Not sure what this is for. Looks like existing types
        return nil
    }
    
    private func renderCode() -> Rendered {
        guard let paths = self.paths else { fatalError("should have set paths") }
        
        let programId = self.programId ?? (self.idl.metadata?.address ?? "")
        var fixableTypes: Set<String> = Set()
        
        let accountFiles = self.accountFilesByType()
        let customFiles = self.customFilesByType()
        
        func forceFixable(ty: IdlType) -> Bool {
            if case .idlTypeDefined(let de) = ty {
                if fixableTypes.contains(de.defined) {
                    return true
                }
            }
            return false
        }
        
        // NOTE: we render types first in order to know which ones are 'fixable' by
        // the time we render accounts and instructions
        // However since types may depend on other types we obtain this info in 2 passes.
        
        // -----------------
        // Types
        // -----------------
        var types: Dictionary<String, String> = [:]
        debugPrint("Rendering \(self.idl.types?.count ?? 0) types" )
        if let idlTypes = self.idl.types {
            for ty in idlTypes {
                debugPrint(ty)
                // Here we detect if the type itself is fixable solely based on its
                // primitive field types
                let isFixable = determineTypeIsFixable(
                    ty: ty,
                    fullFileDir: paths.typesDir(),
                    accountFilesByType: accountFiles,
                    customFilesByType: customFiles
                )
                
                if isFixable {
                    fixableTypes.insert(ty.name)
                }
            }
            
            for ty in idlTypes {
                debugPrint("Rendering type \(ty.name)")
                debugPrint("kind: \(ty.kind)")
                if case .idlDefinedType(let de) = ty.type {
                    debugPrint("fields: \(de.fields)")
                }
                
                if case .idlTypeEnum(let e) = ty.type {
                    debugPrint("variants: \(e.variants)")
                }
                
                
                
                let renderTuple = renderType(
                    ty: ty,
                    fullFileDir: paths.typesDir(),
                    accountFilesByType: accountFiles,
                    customFilesByType: customFiles,
                    typeAliases: self.typeAliases,
                    forceFixable: forceFixable
                )
                
                // If the type by itself does not need to be fixable, here we detect if
                // it needs to be fixable due to including a fixable type
                if renderTuple.isFixable {
                    fixableTypes.insert(ty.name)
                }
                types[ty.name] = renderTuple.code
            }
        }
        
        // -----------------
        // Instructions
        // -----------------
        var instructions: Dictionary<String, String> = [:]
        for ix in self.idl.instructions {
            debugPrint("Rendering instruction \(ix.name)")
            debugPrint("args: \(ix.args)")
            debugPrint("accounts: \(ix.accounts)")
            var code = renderInstruction(
                ix: ix,
                fullFileDir: self.paths!.instructionsDir(),
                programId: programId,
                accountFilesByType: accountFiles,
                customFilesByType: customFiles,
                typeAliases: self.typeAliases,
                forceFixable: forceFixable
            )
            
            if self.prependGeneratedWarning {
                code = prependGeneratedWarningCode(code)
            }
            
            instructions[ix.name] = code
        }
        
        // -----------------
        // Accounts
        // -----------------
        var accounts: Dictionary<String, String> = [:]
        for account in self.idl.accounts ?? [] {
            debugPrint("Rendering account \(account.name)")
            debugPrint("type: \(account.type)")
            var code = renderAccount(
                account: account,
                fullFileDir: self.paths!.accountsDir(),
                accountFilesByType: accountFiles,
                customFilesByType: customFiles,
                typeAliases: self.typeAliases,
                serializers: self.serializers,
                forceFixable: forceFixable,
                programId: programId,
                resolveFieldType: self.resolveFieldType,
                hasImplicitDiscriminator: self.accountsHaveImplicitDiscriminator
            )
            
            if self.prependGeneratedWarning {
                code = prependGeneratedWarningCode(code)
            }
            accounts[account.name] = code
        }
        
        // -----------------
        // Errors
        // -----------------
        debugPrint("Rendering \(self.idl.errors?.count ?? 0) errors")
        var errors = renderErrors(program: self.idl.name, errors: self.idl.errors ?? [])
        
        if let e = errors, self.prependGeneratedWarning {
            errors = prependGeneratedWarningCode(e)
        }
        
        return Rendered(name: idl.name.uppercased(), instructions: instructions, accounts: accounts, types: types, errors: errors)
    }
    
    public func renderAndWriteTo(outputDir: String) {
        self.paths = Paths(outputDir: outputDir, projectName: projectName)
        let rendered = renderCode()
        let instructions = rendered.instructions
        let accounts = rendered.accounts
        let types = rendered.types
        let errors = rendered.errors
        
        var reexports: [String] = []
        
        if self.hasInstructions {
            reexports.append("instructions")
            self.writeInstructions(instructions: instructions)
        }
        
        if !accounts.keys.isEmpty{
            reexports.append("accounts")
            self.writeAccounts(accounts: accounts)
        }
        
        if !types.keys.isEmpty{
            reexports.append("types")
            self.writeTypes(types: types)
        }
        
        if let errors = errors {
            reexports.append("errors")
            self.writeErrors(errorsCode: errors)
        }
        self.writeMainIndex(reexports: reexports)
        self.writeSwiftPackage()
    }
    
    // -----------------
    // Instructions
    // -----------------
    private func writeInstructions(instructions: Dictionary<String, String>) {
        guard let paths = self.paths else { fatalError("should have set paths") }
        prepareTargetDir(dir: paths.instructionsDir())
        debugPrint("Writing instructions to directory: \(paths.relInstructionsDir())")
        for instruction in instructions {
            debugPrint("Writing instruction: \(instruction.key)")
            try! Path(paths.instructionFile(name: instruction.key)).write(instruction.value)
        }
    }
    
    // -----------------
    // Accounts
    // -----------------
    private func writeAccounts(accounts: Dictionary<String, String>) {
        guard let paths = self.paths else { fatalError("should have set paths") }
        prepareTargetDir(dir: paths.accountsDir())
        debugPrint("Writing accounts to directory: \(paths.relAccountsDir())")
        for account in accounts {
            debugPrint("Writing instruction: \(account.key)")
            try! Path(paths.accountFile(name: account.key)).write(account.value)
        }
    }
    
    // -----------------
    // Types
    // -----------------
    private func writeTypes(types: Dictionary<String, String>) {
        guard let paths = self.paths else { fatalError("should have set paths") }
        prepareTargetDir(dir: paths.typesDir())
        debugPrint("Writing types to directory: \(paths.relTypesDir())")
        for type in types {
            debugPrint("Writing instruction: \(type.key)")
            try! Path(paths.typeFile(name: type.key)).write(type.value)
        }
    }
    
    // -----------------
    // Errors
    // -----------------
    private func writeErrors(errorsCode: String) {
        guard let paths = self.paths else { fatalError("should have set paths") }
        prepareTargetDir(dir: paths.errorsDir())
        debugPrint("Writing errors to directory: \(paths.relErrorsDir())")
        debugPrint("Writing index.ts containing all errors")
        try! Path(paths.errorFile(name: "Error")).write(errorsCode)
    }
    
    // -----------------
    // Main Index File
    // -----------------
    
    private func writeMainIndex(reexports: [String]) {
        guard let paths = self.paths else { fatalError("should have set paths") }
        
        let programAddress = self.programId ?? (self.idl.metadata?.address ?? "")
        let programIdConsts =
"""
import Foundation
import Solana

/**
* Program address
*
* @category constants
* @category generated
*/

let PROGRAM_ADDRESS = "\(programAddress)"

/**
* Program public key
*
* @category constants
* @category generated
*/

public let PROGRAM_ID = PublicKey(string: PROGRAM_ADDRESS)
"""
        let code = """
\(programIdConsts)
"""
        try! (paths.root() + Path("Sources") + Path(projectName) + Path("Program.swift")).write(code)
    }
    
    // -----------------
    // Swift Package File
    // -----------------
    
    private func writeSwiftPackage() {
        guard let paths = self.paths else { fatalError("should have set paths") }
        
        let swiftlint =
"""
disabled_rules:
 - identifier_name
 - force_cast
"""
        
        let package =
"""
// swift-tools-version: 5.5.0
import PackageDescription
let package = Package(
    name: "\(projectName)",
    platforms: [.iOS(.v11), .macOS(.v10_12)],
        products: [
            .library(
                name: "\(projectName)",
                targets: ["\(projectName)"]),
    ],
    dependencies: [
        .package(url: "https://github.com/metaplex-foundation/solita-swift.git", branch: "main"),
        .package(name: "Beet", url: "https://github.com/metaplex-foundation/beet-swift.git", from: "1.0.7"),
    ],
    targets: [
        .target(
            name: "\(projectName)",
            dependencies: [
                "Beet",
                .product(name: "BeetSolana", package: "solita-swift")
            ]),
    ]
)
"""
        try! (paths.root() + Path("Package.swift")).write(package)
        try! (paths.root() + Path(".swiftlint.yml")).write(swiftlint)
    }
}

struct Rendered {
    let name: String
    let instructions: Dictionary<String, String>
    let accounts: Dictionary<String, String>
    let types: Dictionary<String, String>
    let errors: String?
}
