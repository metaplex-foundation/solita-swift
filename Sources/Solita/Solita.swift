public class Solita {
    public let idl: Idl
    public var paths: Paths?
    private let hasInstructions: Bool
    private let typeAliases: Dictionary<String, PrimitiveTypeKey>
    private let prependGeneratedWarning: Bool
    public init(idl: Idl, prependGeneratedWarning: Bool=true, typeAliases: Dictionary<String, PrimitiveTypeKey>=[:]) {
        self.idl = idl
        self.hasInstructions = idl.instructions.count > 0
        self.typeAliases = typeAliases
        self.prependGeneratedWarning = prependGeneratedWarning
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
    

    
    private func renderCode() -> Rendered {
        assert(self.paths != nil, "should have set paths")
        
        let programId = self.idl.metadata?.address
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
                    fullFileDir: self.paths!.typesDir(),
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
                    fullFileDir: self.paths!.typesDir(),
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
        let instructions: Dictionary<String, String> = [:]
        for ix in self.idl.instructions {
            debugPrint("Rendering instruction \(ix.name)")
            debugPrint("args: \(ix.args)")
            debugPrint("accounts: \(ix.accounts)")
        }
        
        // -----------------
        // Accounts
        // -----------------
        let accounts: Dictionary<String, String> = [:]
        for account in self.idl.accounts ?? [] {
            debugPrint("Rendering account \(account.name)")
            debugPrint("type: \(account.type)")
        }
        
        // -----------------
        // Errors
        // -----------------
        debugPrint("Rendering \(self.idl.errors?.count ?? 0) errors")
        //let errors = renderErrors(self.idl.errors ?? [])
        
        return Rendered(instructions: instructions, accounts: accounts, types: types, errors: [:])
    }
    
    func renderAndWriteTo(outputDir: String) {
        self.paths = Paths(outputDir: outputDir)
        let rendered = renderCode()
        let reexports: [String] = []
    }
}

struct Rendered {
    let instructions: Dictionary<String, String>
    let accounts: Dictionary<String, String>
    let types: Dictionary<String, String>
    let errors: Dictionary<String, String>
}
