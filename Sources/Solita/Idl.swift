import Foundation

public struct Idl: Codable {
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

public struct IdlMetadata: Codable {
    let address: String
}

public struct IdlEvent: Codable {
    let name: String
    let fields: [IdlEventField]
}

public struct IdlEventField: Codable {
    let name: String
    let type: IdlType
    let index: Bool
}

public struct IdlInstruction: Codable {
    let name: String
    let accounts: [IdlInstructionAccountType]
    let args: [IdlInstructionArg]
}

public struct IdlState: Codable {
    let `struct`: IdlDefinedTypeDefinition
    let methods: [IdlStateMethod]
}

public typealias IdlStateMethod = IdlInstruction

public enum IdlInstructionAccountType: Codable {
    case idlAccount(IdlInstructionAccount)
    case idlAccounts(IdlAccounts)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(IdlInstructionAccount.self) {
            self = .idlAccount(x)
            return
        }
        if let x = try? container.decode(IdlAccounts.self) {
            self = .idlAccounts(x)
            return
        }
        throw DecodingError.typeMismatch(IdlInstructionAccountType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TypeUnion"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .idlAccount(let x):
            try container.encode(x)
        case .idlAccounts(let x):
            try container.encode(x)
        }
    }
}

public struct IdlInstructionAccount: Codable {
    let name: String
    let isMut: Bool
    let isSigner: Bool
}

public struct IdlAccounts: Codable {
    let name: String
    let accounts: [IdlInstructionAccountType]
}

public struct IdlInstructionArg: Codable {
    let name: String
    let type: IdlType
}

public struct IdlField: Codable {
    let name: String
    let type: IdlType
    let attrs: [String]?
}

public struct IdlAccount: Codable {
    let name: String
    let type: IdlDefinedType
}

public struct IdlDefinedTypeDefinition: Codable {
    let name: String
    let type: IdlDefinedType
}

public enum IdlTypeDefTyKind: String, Codable {
    case `struct`
    case `enum`
}

public struct IdlDefinedType: Codable {
    let kind: IdlTypeDefTyKind
    let fields: IdlTypeDefStruct?
    let variants: [IdlEnumVariant]?
}

public typealias IdlTypeDefStruct = [IdlField]

public indirect enum IdlType: Codable {
    case bool
    case u8
    case i8
    case u16
    case i16
    case u32
    case i32
    case u64
    case i64
    case u128
    case i128
    case bytes
    case string
    case publicKey
    case idlTypeVec(IdlTypeVec)
    case idlTypeOption(IdlTypeOption)
    case idlTypeDefined(IdlTypeDefined)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self), x == "bool" {
            self = .bool
            return
        }
        if let x = try? container.decode(String.self), x == "u8" {
            self = .u8
            return
        }
        if let x = try? container.decode(String.self), x == "i8" {
            self = .i8
            return
        }
        if let x = try? container.decode(String.self), x == "u16" {
            self = .u16
            return
        }
        if let x = try? container.decode(String.self), x == "i16" {
            self = .i16
            return
        }
        if let x = try? container.decode(String.self), x == "u32" {
            self = .u32
            return
        }
        if let x = try? container.decode(String.self), x == "i32" {
            self = .i32
            return
        }
        if let x = try? container.decode(String.self), x == "u64" {
            self = .u64
            return
        }
        if let x = try? container.decode(String.self), x == "i64" {
            self = .i64
            return
        }
        if let x = try? container.decode(String.self), x == "u128" {
            self = .u128
            return
        }
        if let x = try? container.decode(String.self), x == "i128" {
            self = .i128
            return
        }
        if let x = try? container.decode(String.self), x == "bytes" {
            self = .bytes
            return
        }
        if let x = try? container.decode(String.self), x == "string" {
            self = .string
            return
        }
        if let x = try? container.decode(String.self), x == "publicKey" {
            self = .publicKey
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
        throw DecodingError.typeMismatch(IdlType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TypeUnion"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool:
            try container.encode("bool")
        case .u8:
            try container.encode("u8")
        case .i8:
            try container.encode("i8")
        case .u16:
            try container.encode("u16")
        case .i16:
            try container.encode("i16")
        case .u32:
            try container.encode("u32")
        case .i32:
            try container.encode("i32")
        case .u64:
            try container.encode("u64")
        case .i64:
            try container.encode("i64")
        case .u128:
            try container.encode("u128")
        case .i128:
            try container.encode("i128")
        case .bytes:
            try container.encode("bytes")
        case .string:
            try container.encode("string")
        case .publicKey:
            try container.encode("publicKey")
        case .idlTypeVec(let x):
            try container.encode(x)
        case .idlTypeOption(let x):
            try container.encode(x)
        case .idlTypeDefined(let x):
            try container.encode(x)
        }
    }
}

public struct IdlTypeVec: Codable {
    let vec: IdlType
}

public struct IdlTypeOption: Codable {
    let option: IdlType
}

// User defined type.
public struct IdlTypeDefined: Codable {
    let defined: String
}

public struct IdlEnumVariant: Codable {
    let name: String
    let fields: IdlEnumFields?
}

public enum IdlEnumFields: Codable {
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .idlEnumFieldsNamed(let x):
            try container.encode(x)
        case .idlEnumFieldsTuple(let x):
            try container.encode(x)
        }
    }
}

public typealias IdlEnumFieldsNamed = [IdlField]

public typealias IdlEnumFieldsTuple = [IdlType]

public struct IdlError: Codable {
    let code: Int
    let name: String
    let msg: String?
}
