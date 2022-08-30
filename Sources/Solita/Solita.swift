import PathKit

public class Solita {
    public let idl: Idl
    public var paths: Paths?
    private let hasInstructions: Bool
    private let accountsHaveImplicitDiscriminator: Bool
    private let typeAliases: Dictionary<String, PrimitiveTypeKey>
    private let serializers: CustomSerializers
    private let prependGeneratedWarning: Bool
    public init(idl: Idl,
                prependGeneratedWarning: Bool=true,
                accountsHaveImplicitDiscriminator: Bool=false,
                typeAliases: Dictionary<String,
                PrimitiveTypeKey>=[:],
                serializers: CustomSerializers?=nil
    ) {
        self.idl = idl
        self.hasInstructions = idl.instructions.count > 0
        self.typeAliases = typeAliases
        self.prependGeneratedWarning = prependGeneratedWarning
        self.accountsHaveImplicitDiscriminator = accountsHaveImplicitDiscriminator
        self.serializers = serializers ?? CustomSerializers.empty()
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
        
        let programId = self.idl.metadata?.address ?? ""
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
                    debugPrint("fields: \(de.fields!)")
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
        
        return Rendered(instructions: instructions, accounts: accounts, types: types, errors: errors)
    }
    
    func renderAndWriteTo(outputDir: String) async {
        self.paths = Paths(outputDir: outputDir)
        
        let rendered = renderCode()
        let instructions = rendered.instructions
        let accounts = rendered.accounts
        let types = rendered.types
        let errors = rendered.errors
        
        var reexports: [String] = []
        
        if self.hasInstructions {
            reexports.append("instructions")
            await self.writeInstructions(instructions: instructions)
        }
        
        if !accounts.keys.isEmpty{
            reexports.append("accounts")
            await self.writeAccounts(accounts: accounts)
        }
        
        if !types.keys.isEmpty{
            reexports.append("types")
            await self.writeTypes(types: types)
        }
        
        if let errors = errors {
            reexports.append("errors")
            await self.writeErrors(errorsCode: errors)
        }
    }
    
    // -----------------
    // Instructions
    // -----------------
    private func writeInstructions(instructions: Dictionary<String, String>) async {
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
    private func writeAccounts(accounts: Dictionary<String, String>) async {
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
    private func writeTypes(types: Dictionary<String, String>) async {
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
    private func writeErrors(errorsCode: String) async {
        guard let paths = self.paths else { fatalError("should have set paths") }
        prepareTargetDir(dir: paths.errorsDir())
        debugPrint("Writing errors to directory: \(paths.relErrorsDir())")
        debugPrint("Writing index.ts containing all errors")
        try! Path(paths.errorFile(name: "Error")).write(errorsCode)
    }
    
    // -----------------
    // Main Index File
    // -----------------
    
    private func writeMainIndex(reexports: [String]) async {
        guard let paths = self.paths else { fatalError("should have set paths") }
        
        let programAddress = self.idl.metadata?.address ?? ""
        let reexportCode = reexports.sorted()
        let programIdConsts =
"""
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
\(reexportCode)
\(programIdConsts)
"""
        try! (paths.root() + Path("Program.swift")).write(code)
    }
}

struct Rendered {
    let instructions: Dictionary<String, String>
    let accounts: Dictionary<String, String>
    let types: Dictionary<String, String>
    let errors: String?
}
