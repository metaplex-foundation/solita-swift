import Foundation

// -----------------
// Guards
// -----------------
func isIdlTypeOption(ty: IdlType) -> Bool {
    if case IdlType.idlTypeOption(let option) = ty {
        return option.option != nil
    } else {
        return false
    }
}

func isIdlTypeVec(ty: IdlType) -> Bool {
    if case IdlType.idlTypeVec(let vec) = ty {
        return vec.vec != nil
    } else {
        return false
    }
}

func isIdlTypeArray(ty: IdlType) -> Bool {
    if case IdlType.idlTypeArray(let array) = ty {
        return array.array != nil
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
        return defined.defined != nil
    } else {
        return false
    }
}

public let BEET_PACKAGE = "Beet"
public let BEET_SOLANA_PACKAGE = "BeetSolana"
public let SOLANA_WEB3_PACKAGE = "Solana"
public let SOLANA_SPL_TOKEN_PACKAGE = "Solana"
public let BEET_EXPORT_NAME = "Beet"
public let BEET_SOLANA_EXPORT_NAME = "BeetSolana"
public let SOLANA_WEB3_EXPORT_NAME = "Solana"
public let SOLANA_SPL_TOKEN_EXPORT_NAME = "Solana"

public let PROGRAM_ID_PACKAGE = "<program-id>"
public let PROGRAM_ID_EXPORT_NAME = "<program-id-export>"
