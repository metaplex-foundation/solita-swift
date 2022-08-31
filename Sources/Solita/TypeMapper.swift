import Foundation
import Beet
import BeetSolana
import PathKit

public typealias ForceFixable = (IdlType) -> Bool
let FORCE_FIXABLE_NEVER: ForceFixable = { _ in return false }

let NO_NAME_PROVIDED = "<no name provided>"

public class TypeMapper {
    public var serdePackagesUsed: Set<SerdePackage> = Set()
    public var localImportsByPath: Dictionary<String, Set<String>> = [:]
    public var scalarEnumsUsed: Dictionary<String, [String]> = [:]
    public var usedFixableSerde: Bool = false
    
    private let accountTypesPaths: Dictionary<String, String>
    private let customTypesPaths: Dictionary<String, String>
    private let typeAliases: Dictionary<String, PrimitiveTypeKey>
    private let forceFixable: ForceFixable
    public let primaryTypeMap: PrimaryTypeMap
    public init(accountTypesPaths: Dictionary<String, String>? = nil,
         customTypesPaths: Dictionary<String, String>? = nil,
         typeAliases: Dictionary<String, PrimitiveTypeKey>? = nil,
         forceFixable: ForceFixable? = nil,
         primaryTypeMap: PrimaryTypeMap? = nil
    ){
        self.accountTypesPaths = accountTypesPaths ?? [:]
        self.customTypesPaths = customTypesPaths ?? [:]
        self.typeAliases = typeAliases ?? [:]
        self.forceFixable = forceFixable ?? FORCE_FIXABLE_NEVER
        self.primaryTypeMap = primaryTypeMap ?? TypeMapper.defaultPrimaryTypeMap
    }
    
    public static var defaultPrimaryTypeMap: PrimaryTypeMap {
        var supported: Dictionary<String, SupportedTypeDefinition> = [:]
        BeetSupportedTypeMap.forEach { supported[$0.0] = $0.1 }
        BeetSolanaSupportedTypeMap.forEach { supported[$0.0] = $0.1 }
        return supported
    }
    
    func clearUsages() {
        self.serdePackagesUsed.removeAll()
        self.localImportsByPath.removeAll()
        self.usedFixableSerde = false
        self.scalarEnumsUsed.removeAll()
    }
    
    func clone() -> TypeMapper{
        return TypeMapper(
            accountTypesPaths: self.accountTypesPaths,
            customTypesPaths: self.customTypesPaths,
            typeAliases: self.typeAliases,
            forceFixable: self.forceFixable,
            primaryTypeMap: self.primaryTypeMap
        )
    }
    
    // -----------------
    // Map TypeScript Type
    // -----------------
    private func mapPrimitiveType(ty: PrimitiveTypeKey, name: String) -> String {
        self.assertBeetSupported(serde: ty, context: "map primitive type")
        let mapped = self.primaryTypeMap[ty]
        var swiftType = mapped?.swift
        
        if swiftType == nil {
            debugPrint("No mapped type found for ${name}: ${ty}, using any")
            swiftType = "Any"
        }
        
        if mapped?.letpack != nil {
            assertKnownSerdePackage(pack: mapped!.letpack!)
            let exp = serdePackageExportName(pack: mapped!.letpack)
            swiftType = "\(exp!.rawValue).\(swiftType!)"
            self.serdePackagesUsed.insert(SerdePackage(rawValue: mapped!.letpack!)!)
        }
        return swiftType!
    }
    
    private func mapKeyType(ty: PrimitiveTypeKey, name: String) -> String {
        self.assertBeetSupported(serde: ty, context: "map primitive type")
        let mapped = self.primaryTypeMap[ty]
        var swiftType = mapped?.swift
        
        if swiftType == nil {
            debugPrint("No mapped type found for ${name}: ${ty}, using any")
            swiftType = "Any"
        }
        
        if mapped?.letpack != nil {
            assertKnownSerdePackage(pack: mapped!.letpack!)
            swiftType = "\(swiftType!)"
            self.serdePackagesUsed.insert(SerdePackage(rawValue: mapped!.letpack!)!)
        }
        return swiftType!
    }
    
    private func mapOptionType(ty: IdlTypeOption, name: String) -> String{
        let inner = self.map(ty: ty.option, name: name)
        let optionPackage = BEET_PACKAGE
        self.serdePackagesUsed.insert(SerdePackage(rawValue: optionPackage)!)
        return "COption<\(inner)>"
    }
    
    private func mapVecType(ty: IdlTypeVec, name: String) -> String{
        let inner = self.map(ty: ty.vec, name: name)
        return "[\(inner)]"
    }
    
    private func mapArrayType(ty: IdlTypeArray, name: String) -> String {
        let inner = self.map(ty: ty.array[0].idlType, name: name)
        let size = ty.array[0].size
        return "[\(inner)] /* size: \(size) */"
    }
    
    private func mapDefinedType(ty: IdlTypeDefined) -> String{
        let fullFileDir = self.definedTypesImport(ty: ty)
                        
        if self.localImportsByPath[fullFileDir] == nil {
            self.localImportsByPath[fullFileDir] = Set()
        }
        self.localImportsByPath[fullFileDir]?.insert(ty.defined)
        return ty.defined
    }
    
    private func mapEnumType(ty: IdlTypeScalarEnum, name: String) -> String{
        assert(
            name != NO_NAME_PROVIDED,
            "Need to provide name for enum types"
        )
        self.updateScalarEnumsUsed(name: name, ty: ty)
        return name
    }
    
    private func mapPrimitiveSerde(ty: PrimitiveTypeKey, name: String) -> String{
        assertBeetSupported(serde: ty, context: "account field \(name)")
        
        if (ty == "string") { return self.mapStringSerde(ty: ty) }
        
        let mapped = self.primaryTypeMap[ty]!
        
        assertKnownSerdePackage(pack: mapped.sourcePack)
        let packExportName = serdePackageExportName(pack: mapped.sourcePack)
        self.serdePackagesUsed.insert(SerdePackage(rawValue: mapped.sourcePack)!)
        self.updateUsedFixableSerde(ty: mapped)
        
        let beet = mapped.isFixable ? "fixableBeat" : "fixedBeet"
        
        return "\(packExportName!.rawValue).\(beet)(\(mapped.beet))"
    }
    
    private func mapPublicKeySerde(ty: PrimitiveTypeKey, name: String) -> String{
        assertBeetSupported(serde: ty, context: "account field \(name)")
               
        let mapped = self.primaryTypeMap[ty]!
        
        assertKnownSerdePackage(pack: mapped.sourcePack)
        self.serdePackagesUsed.insert(SerdePackage(rawValue: mapped.sourcePack)!)
        self.updateUsedFixableSerde(ty: mapped)
        
        return "Beet.fixedBeet(\(mapped.beet))"
    }
    
    private func updateUsedFixableSerde(ty: SupportedTypeDefinition) {
        self.usedFixableSerde = self.usedFixableSerde || ty.isFixable
    }
    
    private func updateScalarEnumsUsed(name: String, ty: IdlTypeScalarEnum) {
        let variants = ty.variants.map{ $0.name }
        let currentUsed = self.scalarEnumsUsed[name]
        
        if (currentUsed != nil) {
            assert( variants == currentUsed,
                    "Found two enum variant specs for \(name), \(variants) and \(currentUsed)"
            )
        } else {
            self.scalarEnumsUsed[name] = variants
        }
    }
    
    private func mapStringSerde(ty: String) -> String{
        let mapped = self.primaryTypeMap[ty]!
        
        assertKnownSerdePackage(pack: mapped.sourcePack)
        let packExportName = serdePackageExportName(pack: mapped.sourcePack)
        
        self.serdePackagesUsed.insert(SerdePackage(rawValue: mapped.sourcePack)!)
        self.updateUsedFixableSerde(ty: mapped)
        let beet = mapped.isFixable ? "fixableBeat" : "fixedBeet"

        return "\(packExportName!.rawValue).\(beet)(\(mapped.beet))"
    }
    
    
    func map(ty: IdlType, name: String = NO_NAME_PROVIDED) -> String {
        if case .beetTypeMapKey(let type) = ty {
            return self.mapPrimitiveType(ty: type.key, name: name)
        }
        
        if case .publicKey(let publicKey) = ty {
            return self.mapKeyType(ty: publicKey.key, name: name)
        }
        
        if case .idlTypeOption(let option) = ty {
            return self.mapOptionType(ty: option, name: name)
        }
        
        if case .idlTypeArray(let array) = ty {
            return self.mapArrayType(ty: array, name: name)
        }
        
        if case .idlTypeVec(let vec) = ty {
            return self.mapVecType(ty: vec, name: name)
        }
        
        if case .idlTypeEnum(let e) = ty {
            return self.mapEnumType(ty: e, name: name)
        }
        
        if case .idlTypeDefined(let defined) = ty {
            if let alias = self.typeAliases[defined.defined] {
                return self.mapPrimitiveType(ty: alias, name: name)
            } else {
                return self.mapDefinedType(ty: defined)
            }
        }
        
        fatalError("Type \(ty) required for \(name) is not yet supported")
    }
    
    public func mapSerdeFields(
        fields: [IdlField]
      ) -> [TypeMappedSerdeField] {
        return fields.map(self.mapSerdeField)
    }
    
    public func mapSerdeField(
        field: IdlField
      ) -> TypeMappedSerdeField {
          let ty = self.mapSerde(ty: field.type, name: field.name)
          return TypeMappedSerdeField(name: field.name, type: ty)
    }
    
    private func mapEnumSerde(ty: IdlTypeScalarEnum, name: String) -> String {
        assert(
            name != NO_NAME_PROVIDED,
            "Need to provide name for enum types"
        )
        let scalarEnumPackage = BEET_PACKAGE
        let exp = serdePackageExportName(pack: BEET_PACKAGE)
        self.serdePackagesUsed.insert(SerdePackage(rawValue: scalarEnumPackage)!)

        self.updateScalarEnumsUsed(name: name, ty: ty)
        return "FixedSizeBeet(value: .scalar( FixedScalarEnum<\(name)>() ))"
    }
    
    private func mapOptionSerde(ty: IdlTypeOption, name: String) -> String {
        let innerSerde = self.mapSerde(ty: ty.option, name: name)
        let optionPackage = BEET_PACKAGE
        
        let mapped = self.primaryTypeMap["option"]!
        self.serdePackagesUsed.insert(SerdePackage(rawValue: optionPackage)!)
        self.usedFixableSerde = true

        let exp = serdePackageExportName(pack: optionPackage)
        return "\(exp!.rawValue).fixableBeat(\(mapped.beet.replacingOccurrences(of: "{inner}", with: "\(innerSerde)")))"
    }
    
    private func mapVecSerde(ty: IdlTypeVec, name: String) -> String {
        let inner = self.mapSerde(ty: ty.vec, name: name)
        let arrayPackage = BEET_PACKAGE

        self.serdePackagesUsed.insert(SerdePackage(rawValue: arrayPackage)!)
        self.usedFixableSerde = true

        let exp = serdePackageExportName(pack: arrayPackage)
        return "\(exp!.rawValue).fixableBeat(array(element: \(inner)))"
    }
    
    private func mapArraySerde(ty: IdlTypeArray, name: String) -> String {
        let inner = self.map(ty: ty.array[0].idlType, name: name)
        
        let mappedInner = self.primaryTypeMap[ty.array[0].idlType.key]!
        
        let size = ty.array[0].size
        let mapped = self.primaryTypeMap["UniformFixedSizeArray"]!
        let arrayPackage = mapped.sourcePack
        assertKnownSerdePackage(pack: arrayPackage)

        self.serdePackagesUsed.insert(SerdePackage(rawValue: arrayPackage)!)
        self.updateUsedFixableSerde(ty: mapped)
        
        let exp = serdePackageExportName(pack: arrayPackage)
        let fixedInnerSerde = mappedInner.beet
        return "\(exp!.rawValue).fixedBeet(\(mapped.beet.replacingOccurrences(of: "{type}", with: "\(inner)").replacingOccurrences(of: "{inner}", with: fixedInnerSerde).replacingOccurrences(of: "{len}", with: "\(size)")))"
    }

    private func mapDefinedSerde(ty: IdlTypeDefined) -> String{
        let fullFileDir = self.definedTypesImport(ty: ty)
        
        let varName = beetVarNameFromTypeName(ty: ty.defined)
        
        if self.localImportsByPath[fullFileDir] == nil {
            self.localImportsByPath[fullFileDir] = Set()
        }
        self.localImportsByPath[fullFileDir]?.insert(varName)
        return "\(varName)Wrapped"
    }

    func mapSerde(ty: IdlType, name: String = NO_NAME_PROVIDED) -> String {
        if (self.forceFixable(ty)) {
            self.usedFixableSerde = true
        }
        
        if case .beetTypeMapKey(let type) = ty {
            return self.mapPrimitiveSerde(ty: type.key, name: name)
        }
        
        if case .publicKey(let publicKey) = ty {
            return self.mapPublicKeySerde(ty: publicKey.key, name: name)
        }
        
        if case .idlTypeArray(let array) = ty {
            return self.mapArraySerde(ty: array, name: name)
        }
        
        if case .idlTypeVec(let vec) = ty {
            return self.mapVecSerde(ty: vec, name: name)
        }
        
        if case .idlTypeOption(let option) = ty {
            return self.mapOptionSerde(ty: option, name: name)
        }
        
        if case .idlTypeEnum(let e) = ty {
            return self.mapEnumSerde(ty: e, name: name)
        }
        
        if case .idlTypeDefined(let defined) = ty {
            if let alias = self.typeAliases[defined.defined] {
                return self.mapPrimitiveSerde(ty: alias, name: name)
            } else {
                return self.mapDefinedSerde(ty: defined)
            }
        }
        
        fatalError("Type \(ty) required for \(name) is not yet supported")
    }
    
    // -----------------
    // Imports Generator
    // -----------------
    func importsUsed(fileDir: Path, forcePackages: Set<SerdePackage>?) -> [String]{
      return _importsForSerdePackages(forcePackages: forcePackages) // + _importsForLocalPackages(fileDir: fileDir)
    }

    private func _importsForSerdePackages(forcePackages: Set<SerdePackage>?) -> [String] {
        let packagesToInclude: Set<SerdePackage>
        if let forcePackages = forcePackages {
            packagesToInclude = self.serdePackagesUsed.union(forcePackages)
        } else {
            packagesToInclude = self.serdePackagesUsed
        }
        
        var imports: [String] = []
        for  pack in packagesToInclude {
            // let exp = serdePackageExportName(pack: pack.rawValue)
            imports.append("import \(pack.rawValue)")
        }
        return imports
    }

    private func _importsForLocalPackages(fileDir: Path) -> [String]{
        var renderedImports: [String] = []
        for x in self.localImportsByPath {
            let originPath = x.key
            let relPath = Path(originPath)
            let importPath = withoutTsExtension(p: relPath.string)
            renderedImports.append("import \(importPath)")
            return renderedImports
        }
        return renderedImports
    }
    
    private func definedTypesImport(ty: IdlTypeDefined) -> String {
        let string = self.accountTypesPaths[ty.defined] ?? self.customTypesPaths[ty.defined]
        if let x = string { return x }
        assertionFailure("Unknown type \(ty.defined) is neither found in types nor an Account")
        return ""
    }
    
    func assertBeetSupported(
        serde: PrimitiveTypeKey,
        context: String
    ) {
        assert(
            self.primaryTypeMap[serde] != nil,
            "Types to \(context) need to be supported by Beet, \(serde) is not"
        )
    }
}
