public class Solita {
    public let idl: Idl
    public var paths: Paths?
    private let hasInstructions: Bool
    public init(idl: Idl) {
        self.idl = idl
        self.hasInstructions = idl.instructions.count > 0
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
        let fixableTypes: Set<String> = Set()
        
        let accountFiles = self.accountFilesByType()
        let customFiles = self.customFilesByType()
        
        // -----------------
        // Types
        // -
        let types: Dictionary<String, String> = [:]
        debugPrint("Rendering \(self.idl.types?.count ?? 0) types" )
        if let types = self.idl.types {
            
            // Here we detect if the type itself is fixable solely based on its
            // primitive field types
            for ty in types {
                debugPrint(ty)
            }
            
            for ty in types {
                debugPrint("Rendering type \(ty.name)")
                debugPrint("kind: \(ty.type.kind)")
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
