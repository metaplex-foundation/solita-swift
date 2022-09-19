import Foundation
import PathKit

public struct PaddingField {
    let name: String
    let size: Int
}

struct AccountResolvedField {
    let name: String
    let swiftType: String
    let isPadding: Bool?
}

func colonSeparatedTypedField(
    readOnly: Bool,
    field: AccountResolvedField,
    prefix:String=""
) -> String {
    return "\(readOnly ? "let" : "var") \(prefix)\(field.name): \(field.swiftType)"
}

class AccountRenderer {
    public let upperCamelAccountName: String
    public let camelAccountName: String
    public let accountDataClassName: String
    public let accountDataArgsTypeName: String
    public let accountDiscriminatorName: String
    public let beetName: String
    public var paddingField: PaddingField?
    
    public let serializerSnippets: SerializerSnippets
    private let programIdPubkey: String
    
    private let account: IdlAccount
    private let fullFileDir: Path
    private let hasImplicitDiscriminator: Bool
    private let resolveFieldType: ResolveFieldType
    private let programId: String
    private let typeMapper: TypeMapper
    private let serializers: CustomSerializers
    
    init(account: IdlAccount,
         fullFileDir: Path,
         hasImplicitDiscriminator: Bool,
         resolveFieldType: @escaping ResolveFieldType,
         programId: String,
         typeMapper: TypeMapper,
         serializers: CustomSerializers
    ){
        self.account = account
        self.fullFileDir = fullFileDir
        self.hasImplicitDiscriminator = hasImplicitDiscriminator
        self.resolveFieldType = resolveFieldType
        self.programId = programId
        self.typeMapper = typeMapper
        self.serializers = serializers
        
        self.upperCamelAccountName = upperCamelCase(ty: account.name).capitalized
        self.camelAccountName = account.name.first!.lowercased() + account.name.dropFirst()
        
        self.accountDataClassName = self.upperCamelAccountName
        self.accountDataArgsTypeName = "\(self.accountDataClassName)Args"
        self.beetName = "\(self.camelAccountName)Beet"
        self.accountDiscriminatorName = "\(self.camelAccountName)Discriminator"
        
        self.serializerSnippets = self.serializers.snippetsFor(
            typeName: self.account.name,
            modulePath: self.fullFileDir.string,
            builtinSerializer: self.beetName
        )
        self.programIdPubkey = "PublicKey(string: \"\(self.programId)\")"
        
        self.paddingField = getPaddingField()
    }
    
    private func getPaddingField() -> PaddingField? {
        let paddingField = self.account.type.fields.filter { hasPaddingAttr(field: $0) }
        if paddingField.count == 0 { return  nil }
        
        assert(
            paddingField.count == 1,
            "only one field of an account can be padding"
        )
        let field = paddingField[0]
        let ty = asIdlTypeArray(ty: field.type)
        let inner = ty.idlType
        let size = ty.size
        assert(inner.key == "u8", "padding field must be [u8]")
        
        return PaddingField(name: field.name, size: size)
    }
    
    private func serdeProcess() -> [TypeMappedSerdeField] {
        return self.typeMapper.mapSerdeFields(fields: self.account.type.fields)
    }
    
    // -----------------
    // Rendered Fields
    // -----------------
    private func getTypedFields() -> [AccountResolvedField] {
        return self.account.type.fields.map { f -> AccountResolvedField in
            let swiftType = self.typeMapper.map(ty: f.type, name: f.name)
            return AccountResolvedField(name: f.name, swiftType: swiftType, isPadding: hasPaddingAttr(field: f))
        }
    }
    
    private func getPrettyFields() -> [String] {
        return self.account.type.fields
            .filter{ !hasPaddingAttr(field: $0) }
            .map { f in
                if case .publicKey = f.type {
                    return "\(f.name): self.\(f.name).toBase58()"
                }
                
                if case .beetTypeMapKey = f.type {
                    return
"""
\(f.name) = {
    return self.\(f.name)
}()
"""
                }
                
                if case .idlTypeDefined(let defined) = f.type {
                    let resolved = defined.defined
                    fatalError("Not implemented")
                }
                
                return "\(f.name): self.\(f.name)"
            }
    }
    
    // -----------------
    // Account Args
    // -----------------
    
    private func renderAccountDataArgsType(
        fields: [AccountResolvedField]
    ) -> String {
        let renderedFields = fields
            .map{ colonSeparatedTypedField(readOnly: false, field: $0) }
            .map{ "\($0) { get }" }
            .joined(separator: "\n    ")
        let renderedDiscriminator = self.hasImplicitDiscriminator ? "\(renderAccountDiscriminatorField()) { get }" : ""
        return
"""
/**
* Arguments used to create {@link \(self.accountDataClassName)}
* @category Accounts
* @category generated
*/
protocol \(self.accountDataArgsTypeName) {
    \(renderedDiscriminator)
    \(renderedFields)
}

"""
    }
    
    private func renderByteSizeMethods() -> String {
        if self.typeMapper.usedFixableSerde {
            
            return
"""
/**
* Returns the byteSize of a {@link Buffer} holding the serialized data of
* {@link \(self.accountDataClassName)} for the provided args.
*
* @param args need to be provided since the byte size for this account
* depends on them
*/
static func byteSize(args: \(self.accountDataArgsTypeName)) -> UInt64 {
    return UInt64(\(self.beetName).toFixedFromValue(val: args).byteSize)
}
/**
* Fetches the minimum balance needed to exempt an account holding
* {@link \(self.accountDataClassName)} data from rent
*
* @param args need to be provided since the byte size for this account
* depends on them
* @param connection used to retrieve the rent exemption information
*/
static func getMinimumBalanceForRentExemption(
    args: \(self.accountDataArgsTypeName),
    connection: Api,
    commitment: Commitment?,
    onComplete: @escaping(Result<UInt64, Error>) -> Void
) {
    return connection.getMinimumBalanceForRentExemption(dataLength: \(self.accountDataClassName).byteSize(args: args), commitment: commitment, onComplete: onComplete)
}
"""
        } else {
            return
"""
  /**
  * Returns the byteSize of a {@link Buffer} holding the serialized data of
  * {@link \(self.accountDataClassName)}
  */
  static func byteSize() -> UInt {
      return \(self.beetName).byteSize
  }
  /**
  * Fetches the minimum balance needed to exempt an account holding
  * {@link \(self.accountDataClassName)} data from rent
  *
  * @param connection used to retrieve the rent exemption information
  */
  static func getMinimumBalanceForRentExemption(
      connection: Api,
      commitment: Commitment?,
      onComplete: @escaping(Result<UInt64, Error>) -> Void
  ) {
      return connection.getMinimumBalanceForRentExemption(dataLength: UInt64(\(self.accountDataClassName).byteSize()), commitment: commitment, onComplete: onComplete)
  }
  /**
  * Determines if the provided {@link Buffer} has the correct byte size to
  * hold {@link \(self.accountDataClassName)} data.
  */
  static func hasCorrectByteSize(buf: Foundation.Data, offset:Int=0) -> Bool {
      return buf.bytes.count - offset == \(self.accountDataClassName).byteSize()
  }
"""
        }
    }
    
    // -----------------
    // Imports
    // -----------------
    private func renderImports() -> String{
        let imports = self.typeMapper.importsUsed(
            fileDir: self.fullFileDir,
            forcePackages: [.SOLANA_WEB3_PACKAGE, .BEET_PACKAGE, .BEET_SOLANA_PACKAGE]
        )
        return imports.joined(separator: "\n")
    }
    
    // -----------------
    // AccountData class
    // -----------------
    private func renderAccountDiscriminatorVar() -> String {
        if !self.hasImplicitDiscriminator { return "" }
        
        let accountDisc = accountDiscriminator(name: self.account.name)
        
        return "let \(self.accountDiscriminatorName) = \(accountDisc.bytes) as [UInt8]"
    }
    
    private func renderAccountDiscriminatorField() -> String {
        if !self.hasImplicitDiscriminator { return "" }
                
        return "var \(self.accountDiscriminatorName): [UInt8]"
    }
    
    private func renderSerializeDictValue(fields: [AccountResolvedField]) -> String {
        var serializeValues:[String] = []
        if self.paddingField != nil {
            //serializeValues.append("padding: [UInt8](repeating: 0, count: \(self.paddingField!.size))")
        }
        
        let constructorParams = fields
            .map{ "\"\($0.name)\" : self.\($0.name)" }
            .joined(separator: ",\n        ")
        
        return
"""
[\(serializeValues.joined(separator: ",\n                "))
        \(constructorParams)
        ]
"""
    }
    
    private func renderSerializeClassValue(argClassName :String, fields: [AccountResolvedField]) -> String {
        var serializeValues:[String] = []
        if self.paddingField != nil {
            //serializeValues.append("padding: [UInt8](repeating: 0, count: \(self.paddingField!.size))")
        }
        
        let constructorParams = fields
            .map{ "\($0.name) : self.\($0.name)" }
            .joined(separator: ",\n        ")
        
        return
"""
\(argClassName)(\(constructorParams))
"""
    }
    
    private func renderAccountDataClass(
        fields: [AccountResolvedField]
    ) -> String {
        var editablefields = fields
        if self.hasImplicitDiscriminator {
            editablefields.insert(AccountResolvedField(name: self.accountDiscriminatorName, swiftType: "[UInt8]", isPadding: false), at: 0)
        }
        let constructorParams = editablefields
            .map{ "\($0.name): args[\"\($0.name)\"] as! \($0.swiftType)" }
            .joined(separator: ",\n        ")
        
        let interfaceRequiredFields = editablefields
            .map{ colonSeparatedTypedField(readOnly: true, field: $0) }
            .map{ "\($0)" }
            .joined(separator: "\n  ")
        
        let byteSizeMethods = self.renderByteSizeMethods()
        let accountDiscriminatorVar = self.renderAccountDiscriminatorVar()
        let serializeValue = self.typeMapper.usedFixableSerde
            ? self.renderSerializeDictValue(fields: editablefields)
            : self.renderSerializeClassValue(argClassName: self.accountDataClassName, fields: editablefields)
        return
"""
\(accountDiscriminatorVar)
/**
 * Holds the data for the {@link \(self.upperCamelAccountName)} Account and provides de/serialization
 * functionality for that data
 *
 * @category Accounts
 * @category generated
 */
public struct \(self.accountDataClassName): \(self.accountDataArgsTypeName) {
  \(interfaceRequiredFields)

  /**
   * Creates a {@link \(self.accountDataClassName)} instance from the provided args.
   */
  public static func fromArgs(args: Args) -> \(self.accountDataClassName) {
    return \(self.accountDataClassName)(
        \(constructorParams)
    )
  }
  /**
   * Deserializes the {@link \(self.accountDataClassName)} from the data of the provided {@link web3.AccountInfo}.
   * @returns a tuple of the account data and the offset up to which the buffer was read to obtain it.
   */
  public static func fromAccountInfo(
    accountInfo: Foundation.Data,
    offset:Int=0
  ) -> ( \(self.accountDataClassName), Int )  {
    return \(self.accountDataClassName).deserialize(buf: accountInfo, offset: offset)
  }
  /**
   * Retrieves the account info from the provided address and deserializes
   * the {@link \(self.accountDataClassName)} from its data.
   *
   * @throws Error if no account info is found at the address or if deserialization fails
   */
  public static func fromAccountAddress(
    connection: Api,
    address: PublicKey,
    onComplete: @escaping (Result<\(self.accountDataClassName), Error>) -> Void
  ) {
    connection.getAccountInfo(account: address.base58EncodedString) { result in
        switch result {
            case .success(let pureData):
                if let data = pureData.data?.value {
                    onComplete(.success(\(self.accountDataClassName).deserialize(buf: data).0))
                } else {
                    onComplete(.failure(SolanaError.nullValue))
                }
            case .failure(let error):
                onComplete(.failure(error))
        }
    }
  }
  /**
   * Deserializes the {@link \(self.accountDataClassName)} from the provided data Buffer.
   * @returns a tuple of the account data and the offset up to which the buffer was read to obtain it.
   */
  public static func deserialize(
    buf: Foundation.Data,
    offset: Int = 0
  ) -> ( \(self.accountDataClassName), Int ) {
    return \(self.serializerSnippets.deserialize)(buffer: buf, offset: offset)
  }
  /**
   * Serializes the {@link \(self.accountDataClassName)} into a Buffer.
   * @returns a tuple of the created Buffer and the offset up to which the buffer was written to store it.
   */
  public func serialize() -> ( Foundation.Data, Int ) {
    return \(self.serializerSnippets.serialize)(instance: \(serializeValue))
  }
  \(byteSizeMethods)
}
"""
    }
    
    // -----------------
    // Struct
    // -----------------
    private func renderBeet(fields: [TypeMappedSerdeField]) -> String {
        var discriminatorName: String? = nil
        var discriminatorField: TypeMappedSerdeField? = nil
        var discriminatorType: String? = nil
        
        if (self.hasImplicitDiscriminator) {
            discriminatorName = "accountDiscriminator"
            discriminatorField = self.typeMapper.mapSerdeField(
                field: anchorDiscriminatorField(name: "accountDiscriminator")
            )
            discriminatorType = anchorDiscriminatorType(
                typeMapper: self.typeMapper,
                context: "account \(self.account.name) discriminant type"
            )
        }
        
        let accountStruct = serdeRenderDataStruct(
            discriminatorName: discriminatorName,
            discriminatorField: discriminatorField,
            discriminatorType: discriminatorType,
            paddingField: self.paddingField,
            fields: fields,
            structVarName: self.beetName,
            className: self.accountDataClassName,
            argsTypename: self.accountDataArgsTypeName,
            isFixable: self.typeMapper.usedFixableSerde
        )
        return
"""
  /**
   * @category Accounts
   * @category generated
   */
  \(accountStruct)
"""
    }
    
    func render() -> String {
        self.typeMapper.clearUsages()
        
        let typedFields = self.getTypedFields()
        let beetFields = self.serdeProcess()
        let enums = renderScalarEnums(map: self.typeMapper.scalarEnumsUsed).joined(separator: "\n")
        let imports = self.renderImports()
        let accountDataArgsType = self.renderAccountDataArgsType(fields: typedFields)
        let accountDataClass = self.renderAccountDataClass(fields: typedFields)
        let beetDecl = self.renderBeet(fields: beetFields)
        return
"""
import Foundation
\(imports)
\(self.serializerSnippets.importSnippet)
\(enums)
\(accountDataArgsType)
\(accountDataClass)
\(beetDecl)
\(self.serializerSnippets.resolveFunctionsSnippet)
"""
    }
}

func renderAccount(
    account: IdlAccount,
    fullFileDir: Path,
    accountFilesByType: Dictionary<String, String>,
    customFilesByType: Dictionary<String, String>,
    typeAliases: Dictionary<String, PrimitiveTypeKey>,
    serializers: CustomSerializers,
    forceFixable: @escaping ForceFixable,
    programId: String,
    resolveFieldType: @escaping ResolveFieldType,
    hasImplicitDiscriminator: Bool
) -> String {
    let typeMapper = TypeMapper(
        accountTypesPaths: accountFilesByType,
        customTypesPaths: customFilesByType,
        typeAliases: typeAliases,
        forceFixable: forceFixable
    )
    let renderer = AccountRenderer(
        account: account,
        fullFileDir: fullFileDir,
        hasImplicitDiscriminator: hasImplicitDiscriminator,
        resolveFieldType: resolveFieldType,
        programId: programId,
        typeMapper: typeMapper,
        serializers: serializers
    )
    return renderer.render()
}

/**
 * Renders DataStruct for Instruction Args and Account Args
 */
public func serdeRenderDataStruct(
    discriminatorName: String?,
    discriminatorField: TypeMappedSerdeField?,
    discriminatorType: String?,
    paddingField: PaddingField?,
    fields: [TypeMappedSerdeField],
    structVarName: String,
    className: String?,
    argsTypename: String,
    isFixable: Bool
) -> String {
    
    var fieldDecls = renderFields(fields: fields)
    let discriminatorDecl = renderField(field: discriminatorField, addSeparator: true)
    let discriminatorType = discriminatorType ?? "[UInt8]"
    var extraFields: [String] = []
    if let discriminatorName = discriminatorName {
        extraFields.append("let \(discriminatorName): \(discriminatorType)")
    }
    
    if let paddingField = paddingField {
        extraFields.append(
            "let \(paddingField.name): [UInt8] /* size: \(paddingField.size) */"
        )
    }
    
    if let className = className {
        let beetStructType = isFixable ? "FixableBeetStruct" : "BeetStruct"
        let renderedStruct =
"""
public let \(structVarName) = \(beetStructType)\(isFixable ? "<\(className)>" : "")(
    fields:[
        \(discriminatorDecl)
        \(fieldDecls)
    ],
    construct: \(className).fromArgs,
    description: \"\(className)\"
)
"""
        if !isFixable { return renderedStruct.replacingOccurrences(of: "Beet.fixedBeet", with: "").replacingOccurrences(of: "Wrapped", with: "")} // Hack to avoid havinf the Beet.fixedBeet on all the types
        return renderedStruct
    } else {
        let beetArgsStructType = "FixableBeetArgsStruct"
        return
"""
public let \(structVarName) = \(beetArgsStructType)<\(argsTypename)>(
    fields: [
        \(discriminatorDecl)
        \(fieldDecls)
    ],
    description: "\(argsTypename)"
)
"""
    }
}

