import Foundation

/**
 * @category TypeDefinition
 */
public enum BeetTypeMapKey: Hashable {
    case collectionsTypeMapKey(CollectionsTypeMapKey)
    case stringTypeMapKey(StringTypeMapKey)
    case compositesTypeMapKey(CompositesTypeMapKey)
    case enumsTypeMapKey(EnumsTypeMapKey)
    case numbersTypeMapKey(NumbersTypeMapKey)
    case aliasesTypeMapKey(AliasesTypeMapKey)
    
    public var key: String {
        switch self {
        case .collectionsTypeMapKey(let key):
            return key.rawValue
        case .stringTypeMapKey(let key):
            return key.rawValue
        case .compositesTypeMapKey(let key):
            return key.rawValue
        case .enumsTypeMapKey(let key):
            return key.rawValue
        case .numbersTypeMapKey(let key):
            return key.rawValue
        case .aliasesTypeMapKey(let key):
            return key.rawValue
        }
    }
}


/**
 * Maps all {@link Beet} de/serializers to metadata which describes in which
 * package it is defined as well as which TypeScript type is used to represent
 * the deserialized value in JavaScript.
 *
 * @category TypeDefinition
 */
public var BeetSupportedTypeMap: Dictionary<String, SupportedTypeDefinition> {
    var supported: Dictionary<String, SupportedTypeDefinition> = [:]
    collectionsTypeMap.forEach { supported[$0.0.rawValue] = $0.1 }
    stringTypeMap.forEach { supported[$0.0.rawValue] = $0.1 }
    compositesTypeMap.forEach { supported[$0.0.rawValue] = $0.1 }
    enumsTypeMap.forEach { supported[$0.0.rawValue] = $0.1 }
    numbersTypeMap.forEach { supported[$0.0.rawValue] = $0.1 }
    aliasesTypeMap.forEach { supported[$0.0.rawValue] = $0.1 }
    return supported
}
