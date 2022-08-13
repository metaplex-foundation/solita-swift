import Foundation

/**
 * Alias for {@link uint8Array}.
 * @category TypeDefinition
 */
public typealias bytes = Uint8Array

public enum AliasesTypeMapKey: String {
    case Uint8Array
}

public typealias AliasesTypeMap = (AliasesTypeMapKey, SupportedTypeDefinition)

public let aliasesTypeMap: [AliasesTypeMap] = [
    (AliasesTypeMapKey.Uint8Array, SupportedTypeDefinition(beet: "uint8Array", isFixable: true, sourcePack: BEET_PACKAGE, swift: "Data", arg: BeetTypeArg.len)),
]
