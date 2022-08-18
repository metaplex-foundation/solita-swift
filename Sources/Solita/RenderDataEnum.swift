import Foundation

/**
 * Renders union type and related methods for Rust data enum.
 */
func renderTypeDataEnumBeet(
    typeMapper: TypeMapper,
    dataEnum: IdlTypeDataEnum,
    beetVarName: String,
    typeName: String
) -> String {
    let enumRecordName = "\(typeName)Record"
    let renderedVariants = dataEnum.variants.map { variant -> (beet: String, usedFixableSerde: Bool) in
        let tm = typeMapper.clone()
        let beet = renderVariant(typeMapper: tm, enumRecordName: enumRecordName, variant: variant)
        for used in tm.serdePackagesUsed {
            typeMapper.serdePackagesUsed.insert(used)
        }
        for dict in tm.scalarEnumsUsed {
            typeMapper.scalarEnumsUsed[dict.key] = dict.value
        }
        typeMapper.usedFixableSerde = typeMapper.usedFixableSerde || tm.usedFixableSerde
        return (beet: beet, usedFixableSerde: tm.usedFixableSerde)
    }
    
    let renderedBeets = renderedVariants
        .map{ $0.beet }
        .joined(separator: ",\n")
    // The size of a data enum is considered non-deterministic even though exceptions
    // exist, i.e. when they have a single variant
    let beetType = "fixableBeat"
    typeMapper.usedFixableSerde = true
    
    return
"""
public let \(beetVarName) = \(BEET_EXPORT_NAME_STRING).\(beetType)(DataEnum<\(enumRecordName)>(variants: [
\(renderedBeets)
]))
"""
}

func renderVariant(
    typeMapper: TypeMapper,
    enumRecordName: String,
    variant: IdlDataEnumVariant
) -> String {
    
    let typeName = "\(enumRecordName)"
    let mappedFields = typeMapper.mapSerdeFields(fields: variant.fields)
    if typeMapper.usedFixableSerde {
        return renderVariantFixable(typeName: typeName, mappedFields: mappedFields, variant: variant)
    } else {
        return renderVariantFixed(typeMapper: typeMapper, typeName: typeName, variant: variant)
    }
}

func renderVariantFixable(typeName: String, mappedFields: [TypeMappedSerdeField], variant: IdlDataEnumVariant) -> String {
    let fieldDecls = mappedFields.map { field -> String in
        let fieldName = upperCamelCase(ty: field.name)
        return "(\"\(fieldName)\", \(field.type))"
    }.joined(separator: ",\n            ")
return """
    (\"\(variant.name)\", \(BEET_EXPORT_NAME_STRING).fixableBeat(FixableBeetArgsStruct<\(typeName)>(fields: [
            \(fieldDecls)
        ],
        description: \"\(typeName)\"
    )))
"""
}

func renderVariantFixed(typeMapper: TypeMapper, typeName: String, variant: IdlDataEnumVariant) -> String {
    
    let fieldDecls = variant.fields.map { field in
        let fieldName = upperCamelCase(ty: field.name)
        let mapped = typeMapper.primaryTypeMap[field.type.key]!
        return "(\"\(fieldName)\", \(mapped.beet))"
    }.joined(separator: ",\n            ")
return """
    (\"\(variant.name)\", Beet.fixedBeet(.init(value: .scalar(BeetArgsStruct(fields: [
            \(fieldDecls)
        ],
        description: \"\(typeName)\"
    )))))
"""
}

func renderDataEnumRecord(
    typeMapper: TypeMapper,
    typeName: String,
    variants: [IdlDataEnumVariant]
) -> String {
    let renderedVariants = variants.map { variant -> String in
        let fields = variant.fields.map { field -> String in
            let swiftType = typeMapper.map(ty: field.type, name: field.name)
            let fieldName = upperCamelCase(ty: field.name)
            return "\(fieldName): \(swiftType)"
        }
        return "case \(variant.name)(\(fields.joined(separator: ", ")))"
    }
    
    return
"""
/**
 * This type is used to derive the {@link \(typeName)} type as well as the de/serializer.
 * However don't refer to it in your code but use the {@link \(typeName)} type instead.
 *
 * @category userTypes
 * @category enums
 * @category generated
 * @private
 */
public enum \(typeName)Record: Equatable {
  \(renderedVariants.joined(separator: "\n  "))
}

extension \(typeName)Record: ConstructableWithDiscriminator {
    public init?(discriminator: UInt8, params: [String: Any]) {
        switch discriminator{
        default: return nil
        }
    }
    
    public static func paramsOrderedKeys(discriminator: UInt8) -> [ParamkeyTypes] {
        switch discriminator{

        default: return []
        }
    }
}

/**
 * Union type respresenting the \(typeName) data enum defined in Rust.
 *
 * @category userTypes
 * @category enums
 * @category generated
 */
public typealias \(typeName) = \(typeName)Record

"""
}
