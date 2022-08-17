import Foundation
import Beet
import BeetSolana

// -----------------
// De/Serializers + Extensions
// -----------------
public typealias PrimitiveTypeKey = String
public typealias PrimaryTypeMap = Dictionary<String, SupportedTypeDefinition>

// -----------------
// Guards
// -----------------
func isIdlTypeOption(ty: IdlType) -> Bool {
    if case IdlType.idlTypeOption(let option) = ty {
        return true
    } else {
        return false
    }
}

func isIdlTypeVec(ty: IdlType) -> Bool {
    if case IdlType.idlTypeVec(let vec) = ty {
        return true
    } else {
        return false
    }
}

func isIdlTypeArray(ty: IdlType) -> Bool {
    if case IdlType.idlTypeArray(let array) = ty {
        return true
    } else {
        return false
    }
}

func asIdlTypeArray(ty: IdlType) -> IdlTypeArrayInner {
    assert(isIdlTypeArray(ty: ty))
    if case IdlType.idlTypeArray(let array) = ty {
        return array.array.first!
    }
    fatalError()
}

func isIdlTypeDefined(ty: IdlType) -> Bool {
    if case IdlType.idlTypeDefined(let defined) = ty {
        return true
    } else {
        return false
    }
}

func isIdlTypeEnum(ty: IdlType) -> Bool {
    if case IdlType.idlTypeEnum(let e) = ty {
        return true
    } else {
        return false
    }
}

public struct TypeMappedSerdeField: Equatable{
    let name: String
    let type: String
}

public let BEET_PACKAGE_STRING = "Beet"
public let BEET_SOLANA_PACKAGE_STRING = "BeetSolana"
public let SOLANA_WEB3_PACKAGE_STRING = "Solana"
public let SOLANA_SPL_TOKEN_PACKAGE_STRING = "Solana"
public let BEET_EXPORT_NAME_STRING = "Beet"
public let BEET_SOLANA_EXPORT_NAME_STRING = "BeetSolana"
public let SOLANA_WEB3_EXPORT_NAME_STRING = "Solana"
public let SOLANA_SPL_TOKEN_EXPORT_NAME_STRING = "Solana"

public let PROGRAM_ID_PACKAGE = "<program-id>"
public let PROGRAM_ID_EXPORT_NAME = "<program-id-export>"
