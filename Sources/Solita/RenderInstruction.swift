import Foundation
import PathKit

public struct ProcessedAccountKey: IdlInstructionAccountProtocol {
    let name: String
    let isMut: Bool
    let isSigner: Bool
    let desc: String?
    let optional: Bool?
    let knownPubkey: ResolvedKnownPubkey?
}

public class InstructionRenderer {
    let upperCamelIxName: String
    let camelIxName: String
    let argsTypename: String
    let accountsTypename: String
    let instructionDiscriminatorName: String
    let structArgName: String
    private let instructionDiscriminator: InstructionDiscriminator
    private let programIdPubkey: String
    
    let ix: IdlInstruction
    let fullFileDir: Path
    let programId: String
    private let typeMapper: TypeMapper
    
    init(
        ix: IdlInstruction,
        fullFileDir: Path,
        programId: String,
        typeMapper: TypeMapper
    ) {
        self.ix = ix
        self.fullFileDir = fullFileDir
        self.programId = programId
        self.typeMapper = typeMapper
        
        self.upperCamelIxName = ix.name.first!.uppercased() + ix.name.dropFirst()
        self.camelIxName = ix.name.first!.lowercased() + ix.name.dropFirst()
        self.argsTypename = "\(self.upperCamelIxName)InstructionArgs"
        self.accountsTypename = "\(self.upperCamelIxName)InstructionAccounts"
        self.instructionDiscriminatorName = "\(self.camelIxName)InstructionDiscriminator"
        self.structArgName = "\(ix.name)Struct"
        self.instructionDiscriminator = InstructionDiscriminator(
            ix: ix,
            fieldName: "instructionDiscriminator",
            typeMapper: typeMapper
        )
        self.programIdPubkey = "PublicKey(string: \"\(self.programId)\")!"
    }
    
    private func renderIxArgField(arg: IdlField) -> String {
        let swiftType = self.typeMapper.map(ty: arg.type, name: arg.name)
        return "\(arg.name): \(swiftType)"
    }
    
    private func renderIxPropertyField(arg: IdlField) -> String {
        let swiftType = self.typeMapper.map(ty: arg.type, name: arg.name)
        return "let \(arg.name): \(swiftType)"
    }
    
    private func renderIxArgsType(
        discriminatorName: String?,
        discriminatorField: TypeMappedSerdeField?,
        discriminatorType: String?
) -> String {
        let fields = self.ix.args.map { renderIxPropertyField(arg: $0) }.joined(separator: "\n    ")
        let discriminatorType = discriminatorType ?? "[UInt8]"
        let code =
"""
/**
 * @category Instructions
 * @category \(self.upperCamelIxName)
 * @category generated
 */
public struct \(self.argsTypename){
    let instructionDiscriminator: \(discriminatorType)
    \(fields)
}
"""
        return code
    }
    
    // -----------------
    // Imports
    // -----------------
    private func renderImports(processedKeys: [ProcessedAccountKey]) -> String {
        let typeMapperImports = self.typeMapper.importsUsed(
            fileDir: self.fullFileDir,
            forcePackages: Set([.SOLANA_WEB3_PACKAGE, .BEET_PACKAGE])
        )
        return "\(typeMapperImports.joined(separator: "\n"))"
    }
    
    // -----------------
    // Accounts
    // -----------------
    private func processIxAccounts() -> [ProcessedAccountKey] {
        return self.ix.accounts.map { account in
            let knownPubkey = resolveKnownPubkey(id: account.name)
            let optional = account.optional ?? false
            return ProcessedAccountKey(name: account.name, isMut: account.isMut, isSigner: account.isSigner, desc: account.desc, optional: optional, knownPubkey: knownPubkey)
        }
    }
    
    private func renderIxAccountKeys(processedKeys: [ProcessedAccountKey]) -> String {
        let requireds = processedKeys.filter { $0.optional != true}
        let optionals = processedKeys.indices.filter {
            let key = processedKeys[$0]
            if key.optional != true { return false }
            assert($0 >= requireds.count, "All optional accounts need to follow required accounts, \(key.name) is not")
            return true
        }.map{ processedKeys[$0] }
        
        let requiredKeys = requireds.map { processedKeys -> String in
            let pubkey = processedKeys.knownPubkey == nil ? "accounts.\(processedKeys.name)"
            : "accounts.\(processedKeys.name) ?? \(renderKnownPubkeyAccess(knownPubkey: processedKeys.knownPubkey!, programIdPubkey: self.programIdPubkey))"
            return
"""
    Account.Meta(
            publicKey: \(pubkey),
            isSigner: \(processedKeys.isSigner),
            isWritable: \(processedKeys.isMut)
        )
"""
        }.joined(separator: ",\n    ")
        var optionalKeys: String
        if optionals.count > 0 {
            optionalKeys = optionals.indices.map { index -> String in
                let key = optionals[index]
                let requiredOptionals = optionals[0..<index]
                let requiredChecks = requiredOptionals
                    .map { "accounts.\($0.name) == nil" }
                    .joined(separator: " || ")
                
                let checkRequireds = requiredChecks.count > 0 ? "if \(requiredChecks) { fatalError(\"When providing \(key.name) \(requiredOptionals.map{ "accounts.\($0.name)"}.joined(separator: ", ")) need(s) to be provided as well.\") }" : ""
                
                return
"""
    if accounts.\(key.name) != nil {
        \(checkRequireds)
        keys.append(
            Account.Meta(
                publicKey: accounts.\(key.name)!,
                isSigner: \(key.isSigner),
                isWritable: \(key.isMut)
            )
        )
    }
"""
            }
            .joined(separator: "\n" ) + "\n"
        } else {
            optionalKeys = ""
        }
        return "[\n    \(requiredKeys)\n    ]\n\(optionalKeys)"
    }
    
    private func renderAccountsType(processedKeys: [ProcessedAccountKey]) -> String {
        if processedKeys.count == 0 { return "" }
        let fields = processedKeys.map { key -> String in
            if key.knownPubkey != nil {
                return "let \(key.name): PublicKey?"
            }
            let optional = key.optional == true ? "?" : ""
            return "let \(key.name): PublicKey\(optional)"
        }.joined(separator: "\n        ")
        
        let propertyComments = processedKeys
            .filter { !isKnownPubkey(id: $0.name) }
            .map { key -> String in
                var attrs:[String] = []
                if key.isMut { attrs.append("_writable_") }
                if key.isSigner { attrs.append("**signer**")}
                
                let optional = key.optional == true ? " (optional) " : " "
                let desc: String = isIdlInstructionAccountWithDesc(ty: key) ? key.desc ?? "" : ""
                return ("* @property [\(attrs.joined(separator: ", "))] " + "\(key.name)\(optional)\(desc) ")
            }
        
        let properties = propertyComments.count > 0 ? "\n*\n\(propertyComments.joined(separator: "\n")) " : ""
        let docs = """
/**
* Accounts required by the _\(self.ix.name)_ instruction\(properties)
* @category Instructions
* @category \(self.upperCamelIxName)
* @category generated
*/
"""
        return
"""
\(docs)
public struct \(self.accountsTypename) {
        \(fields)
}
"""
    }
    
    private func renderAccountsParamDoc(processedKeys: [ProcessedAccountKey]) -> String {
        if processedKeys.count == 0 { return "  *" }
        return
"""
*
* @param accounts that will be accessed while the instruction is processed
"""
    }
    
    private func renderAccountsArg(processedKeys: [ProcessedAccountKey]) -> String{
        if processedKeys.count == 0 { return "" }
        return "accounts: \(self.accountsTypename), \n"
    }
    
    // -----------------
    // Data Struct
    // -----------------
    private func serdeProcess() -> [TypeMappedSerdeField] {
        return self.typeMapper.mapSerdeFields(fields: self.ix.args)
    }
    
    private func renderDataStruct(args: [TypeMappedSerdeField]) -> String{
        let discriminatorField = self.typeMapper.mapSerdeField(
            field: self.instructionDiscriminator.getField()
        )
        let discriminatorType = self.instructionDiscriminator.renderType()
        let instructionStruct = serdeRenderDataStruct(
            discriminatorName: "instructionDiscriminator",
            discriminatorField: discriminatorField,
            discriminatorType: discriminatorType,
            paddingField: nil,
            fields: args,
            structVarName: self.structArgName,
            className: nil ,
            argsTypename: self.argsTypename,
            isFixable: self.typeMapper.usedFixableSerde
        )
        return
"""
/**
 * @category Instructions
 * @category \(self.upperCamelIxName)
 * @category generated
 */
\(instructionStruct)
"""
    }
    
    public func render() -> String {
        self.typeMapper.clearUsages()
        let processedKeys = self.processIxAccounts()
        let accountsType = self.renderAccountsType(processedKeys: processedKeys)
        
        let processedArgs = self.serdeProcess()
        let argsStructType = self.renderDataStruct(args: processedArgs)
        
        
        let keys = self.renderIxAccountKeys(processedKeys: processedKeys)
        let accountsParamDoc = self.renderAccountsParamDoc(processedKeys: processedKeys)
        let accountsArg = self.renderAccountsArg(processedKeys: processedKeys)
        let instructionDisc = self.instructionDiscriminator.renderValue()
        let enums = renderScalarEnums(map: self.typeMapper.scalarEnumsUsed).joined(separator: "\n")
        
        let imports = self.renderImports(processedKeys: processedKeys)
        
        let discriminatorField = self.typeMapper.mapSerdeField(
            field: self.instructionDiscriminator.getField()
        )
        let discriminatorType = self.instructionDiscriminator.renderType()
        let ixArgType = self.renderIxArgsType(discriminatorName: self.instructionDiscriminatorName, discriminatorField: discriminatorField, discriminatorType: discriminatorType)

        var createInstructionArgsComment: String = ""
        var createInstructionArgs: String = ""
        var createInstructionArgsSpread: String = ""
        var comma: String = ""
        
        if ix.args.count > 0 {
            createInstructionArgsComment = "\n  * @param args to provide as instruction data to the program\n * "
            createInstructionArgs = "args: \(self.argsTypename)"
            createInstructionArgsSpread = self.ix.args.map { "\"\($0.name)\": args.\($0.name)" }.joined(separator: ",\n  ")
            comma = ", "
        }
        let optionals = processedKeys.filter{ $0.optional == true }.count
        let programIdArg = "\(comma)programId: PublicKey=\(self.programIdPubkey)"
        return
"""
import Foundation
\(imports)
\(enums)
\(ixArgType)
\(argsStructType)
\(accountsType)

public let \(self.instructionDiscriminatorName) = \(instructionDisc)

/**
* Creates a _\(self.upperCamelIxName)_ instruction.
\(accountsParamDoc)\(createInstructionArgsComment)
* @category Instructions
* @category \(self.upperCamelIxName)
* @category generated
*/
public func create\(self.upperCamelIxName)Instruction(\(accountsArg)\(createInstructionArgs)\(programIdArg)) -> TransactionInstruction {

    let data = \(self.structArgName).serialize(
            instance: ["instructionDiscriminator": \(self.instructionDiscriminatorName)\(createInstructionArgsSpread == "" ? " ": ",\n")\(createInstructionArgsSpread)],  byteSize: nil
    )

    \((optionals > 0) ? "var" : "let") keys: [Account.Meta] = \(keys)
    let ix = TransactionInstruction(
                keys: keys,
                programId: programId,
                data: data.0.bytes
            )
    return ix
}
"""
    }
}

public func renderInstruction(
    ix: IdlInstruction,
    fullFileDir: Path,
    programId: String,
    accountFilesByType: Dictionary<String, String>,
    customFilesByType: Dictionary<String, String>,
    typeAliases: Dictionary<String, PrimitiveTypeKey>,
    forceFixable: @escaping ForceFixable
)  -> String {
    let typeMapper = TypeMapper(
        accountTypesPaths: accountFilesByType,
        customTypesPaths: customFilesByType,
        typeAliases: typeAliases,
        forceFixable: forceFixable
    )
    let renderer = InstructionRenderer(
        ix: ix,
        fullFileDir: fullFileDir,
        programId: programId,
        typeMapper: typeMapper
    )
    return renderer.render()
}
