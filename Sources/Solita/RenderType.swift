import Foundation
import PathKit
import Beet

public class TypeRenderer {
    public let upperCamelTyName: String
    public let camelTyName: String
    public let beetArgName: String
    
    public let ty: IdlDefinedTypeDefinition
    public let fullFileDir: Path
    public let typeMapper: TypeMapper
    
    public init(ty: IdlDefinedTypeDefinition,
         fullFileDir: Path,
         typeMapper: TypeMapper = TypeMapper()){
        self.ty = ty
        self.fullFileDir = fullFileDir
        self.typeMapper = typeMapper
        
        self.upperCamelTyName = ty.name.first!.uppercased() + ty.name.dropFirst()
        self.camelTyName = ty.name.first!.lowercased() + ty.name.dropFirst()
        self.beetArgName = beetVarNameFromTypeName(ty: ty.name)
    }
    
    // -----------------
    // Rendered Fields
    // -----------------
    private func renderTypeField(field: IdlField) -> String {
        let swiftType = self.typeMapper.map(ty: field.type, name: field.name)
        return "let \(field.name): \(swiftType)"
    }
    
    private func renderSwiftType() -> String {
        if case .idlTypeDataEnum(let de) = ty.type {
            return renderDataEnumRecord(
                typeMapper: self.typeMapper,
                typeName: self.ty.name,
                variants: de.variants
            )
        }
        
        if case .idlTypeEnum(let e) = ty.type {
            return renderScalarEnum(name: ty.name, variants: e.variants.map{ $0.name }, includePublic: true)
        }
        
        if case .idlDefinedType(let d) = ty.type {
            if d.fields?.count == 0 { return "" }
            let fields = d.fields!.map{ renderTypeField(field: $0) }.joined(separator: "\n    ")
            return
"""
public struct \(upperCamelTyName) {
    \(fields)
}
"""
        }
        return ""
    }
    
    // -----------------
    // Imports
    // -----------------
    private func renderImports() -> String {
        let imports = self.typeMapper.importsUsed(
            fileDir: self.fullFileDir,
            forcePackages: Set([.BEET_PACKAGE])
        )
        return imports.joined(separator: "\n")
    }
    
    // -----------------
    // Data Struct/Enum
    // -----------------
    private func renderDataStructOrEnum() -> String {
        if case .idlTypeDataEnum(let de) = ty.type {
            return renderTypeDataEnumBeet(
                    typeMapper: self.typeMapper,
                    dataEnum: de,
                    beetVarName: self.beetArgName,
                    typeName: self.upperCamelTyName
            )
        }
        
        if case .idlTypeEnum(let e) = ty.type {
            let serde = self.typeMapper.mapSerde(ty: .idlTypeEnum(e), name: self.ty.name)
            let enumTy = self.typeMapper.map(ty: .idlTypeEnum(e), name: self.ty.name)
            self.typeMapper.serdePackagesUsed.insert(.BEET_PACKAGE)
            let exp = serdePackageExportName(pack: BEET_PACKAGE)
            return "public let \(self.beetArgName) = \(exp!.rawValue).FixedSizeBeet(value: \(serde))"
        }
        if case .idlDefinedType(let d) = ty.type {
            let mappedFields = self.typeMapper.mapSerdeFields(fields: d.fields!)
            return renderTypeDataStruct(
                  fields: mappedFields,
                  beetVarName: self.beetArgName,
                  typeName: self.upperCamelTyName,
                  isFixable: self.typeMapper.usedFixableSerde
            )
        }
        
        return ""
    }
    
    private func renderDataStructs() -> (String, String){
        let renderSwiftType = self.renderSwiftType()
        let dataStruct = self.renderDataStructOrEnum()
        return (renderSwiftType, dataStruct)
    }
    /**
       * Performs parts of the render process that is necessary to determine if the
       * type is fixed or fixable.
       */
    func determineIsFixable() -> Bool{
        self.typeMapper.clearUsages()
        self.renderDataStructs()
        return self.typeMapper.usedFixableSerde
    }
    
    public func render() -> String {
        typeMapper.clearUsages()
        let structs = renderDataStructs()
        let imports = renderImports()
        return
"""
\(imports)

\(structs.0)

/**
 * @category userTypes
 * @category generated
 */
\(structs.1)
"""
    }
}

func beetVarNameFromTypeName(ty: String) -> String {
    let camelTyName = ty.first!.lowercased() + ty.dropFirst()
    return "\(camelTyName)Beet"
}

func upperCamelCase(ty: String) -> String {
    return ty.split(separator: " ")
        .map { String($0) }
        .enumerated()
        .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
        .joined()
}


/**
 * Performs parts of the render process that is necessary to determine if the
 * type is fixed or fixable.
 */
public func determineTypeIsFixable(
  ty: IdlDefinedTypeDefinition,
  fullFileDir: Path,
  accountFilesByType: Dictionary<String, String>,
  customFilesByType: Dictionary<String, String>
) -> Bool {
    let typeMapper =  TypeMapper(accountTypesPaths: accountFilesByType, customTypesPaths: customFilesByType)
    let renderer =  TypeRenderer(ty: ty, fullFileDir: fullFileDir, typeMapper: typeMapper)
    return renderer.determineIsFixable()
}

public func renderType(
  ty: IdlDefinedTypeDefinition,
  fullFileDir: Path,
  accountFilesByType: Dictionary<String, String>,
  customFilesByType: Dictionary<String, String>,
  typeAliases: Dictionary<String, PrimitiveTypeKey>,
  forceFixable: @escaping ForceFixable
) -> (code: String, isFixable: Bool) {
  let typeMapper = TypeMapper(
    accountTypesPaths: accountFilesByType,
    customTypesPaths: customFilesByType,
    typeAliases: typeAliases,
    forceFixable: forceFixable
  )
    let renderer = TypeRenderer(ty: ty, fullFileDir: fullFileDir, typeMapper: typeMapper)
    let code = renderer.render()
    let isFixable = renderer.typeMapper.usedFixableSerde
  return (code, isFixable)
}
