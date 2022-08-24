import Foundation


public enum SerdePackage: RawRepresentable {
    case BEET_PACKAGE
    case BEET_SOLANA_PACKAGE
    case SOLANA_WEB3_PACKAGE
    
    public typealias RawValue = String
    public init?(rawValue: String) {
        switch rawValue{
        case BEET_PACKAGE_STRING: self = .BEET_PACKAGE
        case BEET_SOLANA_PACKAGE_STRING: self = .BEET_SOLANA_PACKAGE
        case SOLANA_WEB3_PACKAGE_STRING: self = .SOLANA_WEB3_PACKAGE
        default: fatalError("Unkown Package")
        }
    }
    public var rawValue: String {
        switch self {
        case .BEET_PACKAGE: return BEET_PACKAGE_STRING
        case .BEET_SOLANA_PACKAGE: return BEET_SOLANA_PACKAGE_STRING
        case .SOLANA_WEB3_PACKAGE: return SOLANA_WEB3_PACKAGE_STRING
        }
    }
}
public enum SerdePackageExportName: RawRepresentable {
    case BEET_EXPORT_NAME
    case BEET_SOLANA_EXPORT_NAME
    case SOLANA_WEB3_EXPORT_NAME
    
    public typealias RawValue = String
    public init?(rawValue: String) {
        switch rawValue{
        case BEET_EXPORT_NAME_STRING: self = .BEET_EXPORT_NAME
        case BEET_SOLANA_EXPORT_NAME_STRING: self = .BEET_SOLANA_EXPORT_NAME
        case SOLANA_WEB3_EXPORT_NAME_STRING: self = .SOLANA_WEB3_EXPORT_NAME
        default: fatalError("Unkown Package")
        }
    }
    public var rawValue: String {
        switch self {
        case .BEET_EXPORT_NAME: return BEET_EXPORT_NAME_STRING
        case .BEET_SOLANA_EXPORT_NAME: return BEET_SOLANA_EXPORT_NAME_STRING
        case .SOLANA_WEB3_EXPORT_NAME: return SOLANA_WEB3_EXPORT_NAME_STRING
        }
    }
}


public let serdePackages: Dictionary<SerdePackage, SerdePackageExportName> =
[
    SerdePackage.BEET_PACKAGE: SerdePackageExportName.BEET_EXPORT_NAME,
    SerdePackage.BEET_SOLANA_PACKAGE: SerdePackageExportName.BEET_SOLANA_EXPORT_NAME,
    SerdePackage.SOLANA_WEB3_PACKAGE: SerdePackageExportName.SOLANA_WEB3_EXPORT_NAME,
]

public func serdePackageExportName(
    pack: String?
) -> SerdePackageExportName? {
    
    guard let pack = pack, let serdePackage = SerdePackage(rawValue: pack) else { return nil }
    
    let exportName = serdePackages[serdePackage]
    assert(exportName != nil, "Unknown serde package \(serdePackage.rawValue)")
    return exportName
}

func isKnownSerdePackage(pack: String) -> Bool {
    return (
        pack == BEET_PACKAGE_STRING ||
        pack == BEET_SOLANA_PACKAGE_STRING ||
        pack == SOLANA_WEB3_PACKAGE_STRING
    )
}

func assertKnownSerdePackage(
    pack: String
){
    assert(
        isKnownSerdePackage(pack: pack),
        "\(pack) is an unknown and thus not yet supported de/serializer package"
    )
}

// -----------------
// Rendering processed serdes to struct
// -----------------

public func renderField(field: TypeMappedSerdeField?, addSeparator: Bool = false) -> String{
    let sep = addSeparator ? "," : ""
    return field == nil ? "" : "(\"\(field!.name)\", \(field!.type))\(sep)"
}

public func renderFields(fields: [TypeMappedSerdeField]?) -> String {
    return fields == nil || fields!.count == 0 ? "" : fields!.map { renderField(field: $0) }.joined(separator: ",\n    ")
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
    
    let fieldDecls = renderFields(fields: fields)
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
public let \(structVarName) = \(beetStructType)<\(className)>(
    fields:[
        \(discriminatorDecl)
        \(fieldDecls)
    ],
    construct: \(className).fromArgs,
    description: \"\(className)\"
)
"""
        if !isFixable { return renderedStruct.replacingOccurrences(of: "Beet.fixedBeet", with: "")} // Hack to avoid havinf the Beet.fixedBeet on all the types
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

/**
 * Renders DataStruct for user defined types
 */
public func renderTypeDataStruct(
    fields: [TypeMappedSerdeField],
    beetVarName: String,
    typeName: String,
    isFixable: Bool
) -> String {
    assert( fields.count > 0, "Rendering struct for \(typeName) should have at least 1 field" )
    if isFixable {
        return renderTypeDataFixableBeetArgsStruct(fields: fields, beetVarName: beetVarName, typeName: typeName)
    } else {
        return renderTypeDataBeetArgsStruct(fields: fields, beetVarName: beetVarName, typeName: typeName)
    }
}


func renderTypeDataFixableBeetArgsStruct(
    fields: [TypeMappedSerdeField],
    beetVarName: String,
    typeName: String
) -> String {
    assert( fields.count > 0, "Rendering struct for \(typeName) should have at least 1 field" )
    let fieldDecls = fields.map{ "(\"\($0.name)\", \($0.type))" }.joined(separator: ",\n    ")
    let beetArgsStructType = "FixableBeetArgsStruct"
    
    return """
public let \(beetVarName) = \(beetArgsStructType)<\(typeName)>(fields: [
    \(fieldDecls)
], description: "\(typeName)")
"""
}

func renderTypeDataBeetArgsStruct(
    fields: [TypeMappedSerdeField],
    beetVarName: String,
    typeName: String
) -> String {
    assert( fields.count > 0, "Rendering struct for \(typeName) should have at least 1 field" )
    let fieldDecls = fields.map{ "(\"\($0.name)\", \($0.type))" }.joined(separator: ",\n    ")
    let beetArgsStructType = "BeetArgsStruct"
    
    return """
public let \(beetVarName) = \(beetArgsStructType)<\(typeName)>(fields: [
    \(fieldDecls)
], description: "\(typeName)")
"""
}
