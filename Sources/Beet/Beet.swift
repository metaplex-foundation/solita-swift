import Foundation

/**
 * @category TypeDefinition
 */
public enum BeetTypeMapKey {
    case collectionsTypeMapKey(CollectionsTypeMapKey)
    case stringTypeMapKey(StringTypeMapKey)
    case compositesTypeMapKey(CompositesTypeMapKey)
    case enumsTypeMapKey(EnumsTypeMapKey)
    case numbersTypeMapKey(NumbersTypeMapKey)
    case aliasesTypeMapKey(AliasesTypeMapKey)
}
