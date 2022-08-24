import Foundation
import Beet
import BeetSolana

protocol ParseableIDL: Decodable {
    var version: String { get }
    var name: String { get }
    var instructions: [IdlInstruction] { get }
    var state: IdlState? { get }
    var accounts: [IdlAccount]? { get }
    var types: [IdlDefinedTypeDefinition]? { get }
    var events: [IdlEvent]? { get }
    var errors: [IdlError]? { get }
}

public struct Idl: Decodable {
    let version: String
    let name: String
    let instructions: [IdlInstruction]
    let state: IdlState?
    let accounts: [IdlAccount]?
    let types: [IdlDefinedTypeDefinition]?
    let events: [IdlEvent]?
    let errors: [IdlError]?
    let metadata: IdlMetadata?
}

public struct ShankIdl: ParseableIDL {
    let version: String
    let name: String
    let instructions: [IdlInstruction]
    let state: IdlState?
    let accounts: [IdlAccount]?
    let types: [IdlDefinedTypeDefinition]?
    let events: [IdlEvent]?
    let errors: [IdlError]?
    let metadata: ShankMetadata?
}

public struct ShankMetadata: Decodable {
    let address: String
    var origin: String = "shank"
}

public struct IdlMetadata: Decodable {
    let address: String
}

public struct IdlEvent: Decodable {
    let name: String
    let fields: [IdlEventField]
}

public struct IdlEventField: Decodable {
    let name: String
    let type: IdlType
    let index: Bool
}

public struct IdlInstruction: Decodable {
    let name: String
    let accounts: [IdlInstructionAccount]
    let args: [IdlField]
}

public struct IdlState: Decodable {
    let `struct`: IdlDefinedTypeDefinition
    let methods: [IdlStateMethod]
}

public typealias IdlStateMethod = IdlInstruction

public enum IdlInstructionAccountType: Decodable {
    case idlAccount(IdlInstructionAccount)
    case idlAccounts(IdlInstructionAccounts)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(IdlInstructionAccount.self) {
            self = .idlAccount(x)
            return
        }
        if let x = try? container.decode(IdlInstructionAccounts.self) {
            self = .idlAccounts(x)
            return
        }
        throw DecodingError.typeMismatch(IdlInstructionAccountType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for IdlInstructionAccountType"))
    }
}

protocol IdlInstructionAccountProtocol {
    var name: String { get }
    var isMut: Bool { get }
    var isSigner: Bool { get }
    var desc: String? { get }
    var optional: Bool? { get }
}

public struct IdlInstructionAccount: IdlInstructionAccountProtocol & Decodable{
    let name: String
    let isMut: Bool
    let isSigner: Bool
    let desc: String?
    let optional: Bool?
}

public struct IdlInstructionAccounts: Decodable {
    let name: String
    let accounts: [IdlInstructionAccountType]
}

public struct IdlInstructionArg: Decodable {
    let name: String
    let type: IdlType
}

public struct IdlField: Decodable {
    let name: String
    let type: IdlType
    let attrs: [String]?
}

public struct IdlAccount: Decodable {
    let name: String
    let type: IdlDefinedType
}

public enum IdlDefinedTypeDefinitionType {
    case idlDefinedType(IdlDefinedType)
    case idlTypeEnum(IdlTypeScalarEnum)
    case idlTypeDataEnum(IdlTypeDataEnum)
}

public struct IdlDefinedTypeDefinition {
    let name: String
    let type: IdlDefinedTypeDefinitionType
    private enum CodingKeys: String, CodingKey { case name, type}
    
    var kind: String {
        switch self.type {
        case .idlDefinedType(let type):
            return type.kind.rawValue
        case .idlTypeEnum(let e):
            return e.kind
        case .idlTypeDataEnum(let de):
            return de.kind
        }
    }
}

extension IdlDefinedTypeDefinition: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let x = try? container.decode(IdlDefinedType.self, forKey: .type) {
            self.name = try container.decode(String.self, forKey: .name)
            self.type = .idlDefinedType(x)
            return
        }
        if let x = try? container.decode(IdlTypeScalarEnum.self, forKey: .type) {
            self.name = try container.decode(String.self, forKey: .name)
            self.type = .idlTypeEnum(x)
            return
        }
        if let x = try? container.decode(IdlTypeDataEnum.self, forKey: .type) {
            self.name = try container.decode(String.self, forKey: .name)
            self.type = .idlTypeDataEnum(x)
            return
        }
        throw DecodingError.typeMismatch(IdlDefinedTypeDefinition.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for IdlDefinedTypeDefinition"))
    }
}

public enum IdlTypeDefTyKind: String, Decodable {
    case `struct`
    case `enum`
}

public struct IdlDefinedType: Decodable {
    let kind: IdlTypeDefTyKind
    let fields: IdlTypeDefStruct?
}

public typealias IdlTypeDefStruct = [IdlField]

public struct IdlTypeScalarEnum: Decodable {
    let kind: String = "enum"
    let variants: [IdlEnumVariant]
}

public struct IdlTypeDataEnum: Decodable {
    let kind: String = "enum"
    let variants: [IdlDataEnumVariant]
}

public struct IdlDataEnumVariant: Decodable {
  let name: String
  let fields: [IdlField]
}

public indirect enum IdlType: Decodable {
    case beetTypeMapKey(BeetTypeMapKey)
    case publicKey(BeetSolanaTypeMapKey)
    case idlTypeDefined(IdlTypeDefined)
    case idlTypeOption(IdlTypeOption)
    case idlTypeVec(IdlTypeVec)
    case idlTypeArray(IdlTypeArray)
    case idlTypeEnum(IdlTypeScalarEnum)
    case idlTypeDataEnum(IdlTypeDataEnum)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self){
            self = try IdlType.init(fromKey: x, from: decoder)
            return
        }        
        if let x = try? container.decode(IdlTypeArray.self) {
            self = .idlTypeArray(x)
            return
        }
        if let x = try? container.decode(IdlTypeVec.self) {
            self = .idlTypeVec(x)
            return
        }
        if let x = try? container.decode(IdlTypeOption.self) {
            self = .idlTypeOption(x)
            return
        }
        if let x = try? container.decode(IdlTypeDefined.self) {
            self = .idlTypeDefined(x)
            return
        }
        
        throw DecodingError.typeMismatch(IdlType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for IdlType"))
    }
    
    fileprivate init(fromKey: String, from decoder: Decoder) throws {
        if let number = NumbersTypeMapKey(rawValue: fromKey){
            self = .beetTypeMapKey(.numbersTypeMapKey(number))
            return
        }
        if let string = StringTypeMapKey(rawValue: fromKey){
            self = .beetTypeMapKey(.stringTypeMapKey(string))
            return
        }
        
        if let composite = CompositesTypeMapKey(rawValue: fromKey){
            self = .beetTypeMapKey(.compositesTypeMapKey(composite))
            return
        }
        
        if let enums = EnumsTypeMapKey(rawValue: fromKey){
            self = .beetTypeMapKey(.enumsTypeMapKey(enums))
            return
        }
        
        if let aliases = AliasesTypeMapKey(rawValue: fromKey){
            self = .beetTypeMapKey(.aliasesTypeMapKey(aliases))
            return
        }
        if fromKey == "bytes" {
            self = .beetTypeMapKey(.aliasesTypeMapKey(.Uint8Array))
            return
        }
        if let publicKey = KeysTypeMapKey(rawValue: fromKey){
            self = .publicKey(.keysTypeMapKey(publicKey))
            return
        }
        throw DecodingError.typeMismatch(IdlType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Not a valid Key: \(fromKey)"))
    }
    
    var key: String {
        switch self {
        case .beetTypeMapKey(let beetType):
            return beetType.key
        case .publicKey(let publicKey):
            return publicKey.key
        default: return ""
        }
    }
}

public struct IdlTypeArrayInner: Decodable {
    let idlType: IdlType
    let size: Int
}

public struct IdlTypeArray {
    let array: [IdlTypeArrayInner]
}

extension IdlTypeArray: Decodable {
    private enum CodingKeys: String, CodingKey { case array }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tempArray = try container.decode([Any].self, forKey: .array)
        if let string = tempArray[0] as? String {
            array = [IdlTypeArrayInner(idlType: try IdlType(fromKey: string, from: decoder), size: tempArray[1] as! Int)]
        } else {
            throw DecodingError.typeMismatch(IdlType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Inner nested Types not supported yet"))
        }
    }
}

public struct IdlTypeVec: Decodable {
    let vec: IdlType
}

public struct IdlTypeOption: Decodable {
    let option: IdlType
}

// User defined type.
public struct IdlTypeDefined: Decodable {
    let defined: String
}

public struct IdlEnumVariant: Decodable {
    let name: String
    let fields: IdlEnumFields?
}

public enum IdlEnumFields: Decodable {
    case idlEnumFieldsNamed(IdlEnumFieldsNamed)
    case idlEnumFieldsTuple(IdlEnumFieldsTuple)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(IdlEnumFieldsNamed.self) {
            self = .idlEnumFieldsNamed(x)
            return
        }
        if let x = try? container.decode(IdlEnumFieldsTuple.self) {
            self = .idlEnumFieldsTuple(x)
            return
        }
        throw DecodingError.typeMismatch(IdlEnumFields.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TypeUnion"))
    }
}

public typealias IdlEnumFieldsNamed = [IdlField]

public typealias IdlEnumFieldsTuple = [IdlType]

public struct IdlError: Codable {
    let code: Int
    let name: String
    let msg: String?
}
