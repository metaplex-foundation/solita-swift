import XCTest
@testable import Solita
import PathKit

let SOME_FILE_DIR = Path("/root/app/")

final class TypeMapperTests: XCTestCase {
    // -----------------
    // Primitive Types
    // -----------------
    func testTypeMapperPrimitiveTypeI8() {
        let tm = TypeMapper()
        let types: Array<IdlType> = [.beetTypeMapKey(.numbersTypeMapKey(.i8))]
        for type in types {
            let ty = tm.map(ty: type)
            XCTAssert(ty == "Int8", "'\(type)' maps to '\(ty)' TypeScript type")
        }
        XCTAssert(!tm.usedFixableSerde,"did not use fixable serde")
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        tm.clearUsages()
        for type in types {
            let serde = tm.mapSerde(ty: type)
            XCTAssert(serde == "Beet.fixedBeet(.init(value: .scalar(i8())))", "'\(type)' maps to '\(serde)' serde")
        }
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(!tm.usedFixableSerde,"did not use fixable serde")
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
    }
    
    func testTypeMapperPrimitiveTypeU32() {
        let tm = TypeMapper()
        let types: Array<IdlType> = [.beetTypeMapKey(.numbersTypeMapKey(.u32))]
        for type in types {
            let ty = tm.map(ty: type)
            XCTAssert(ty == "UInt32", "'\(type)' maps to '\(ty)' TypeScript type")
        }
        XCTAssert(!tm.usedFixableSerde,"did not use fixable serde")
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        tm.clearUsages()
        for type in types {
            let serde = tm.mapSerde(ty: type)
            XCTAssert(serde == "Beet.fixedBeet(.init(value: .scalar(u32())))", "'\(type)' maps to '\(serde)' serde")
        }
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(!tm.usedFixableSerde,"did not use fixable serde")
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
    }
    
    func testTypeMapperPrimitiveTypeU128() {
        let tm = TypeMapper()
        let types: Array<IdlType> = [.beetTypeMapKey(.numbersTypeMapKey(.u128))]
        for type in types {
            let ty = tm.map(ty: type)
            XCTAssert(ty == "UInt128", "'\(type)' maps to '\(ty)' TypeScript type")
        }
        XCTAssert(!tm.usedFixableSerde,"did not use fixable serde")
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        tm.clearUsages()
        for type in types {
            let serde = tm.mapSerde(ty: type)
            XCTAssert(serde == "Beet.fixedBeet(.init(value: .scalar(u128())))", "'\(type)' maps to '\(serde)' serde")
        }
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(!tm.usedFixableSerde,"did not use fixable serde")
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
    }
    
    func testTypeMapperPrimitiveTypeI512() {
        let tm = TypeMapper()
        let types: Array<IdlType> = [.beetTypeMapKey(.numbersTypeMapKey(.i512))]
        for type in types {
            let ty = tm.map(ty: type)
            XCTAssert(ty == "Int512", "'\(type)' maps to '\(ty)' TypeScript type")
        }
        XCTAssert(!tm.usedFixableSerde,"did not use fixable serde")
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        tm.clearUsages()
        for type in types {
            let serde = tm.mapSerde(ty: type)
            XCTAssert(serde == "Beet.fixedBeet(.init(value: .scalar(i512())))", "'\(type)' maps to '\(serde)' serde")
        }
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(!tm.usedFixableSerde,"did not use fixable serde")
    }
    
    func testTypeMapperStrings() {
        let tm = TypeMapper()
        let types: Array<IdlType> = [.beetTypeMapKey(.stringTypeMapKey(.string))]
        for type in types {
            let ty = tm.map(ty: type)
            XCTAssert(ty == "String", "'\(type)' maps to '\(ty)' TypeScript type")
        }
        XCTAssert(tm.serdePackagesUsed.count == 0, "no serdePackagesUsed")
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        tm.clearUsages()
        
        for type in types {
            let serde = tm.mapSerde(ty: type)
            XCTAssert(serde == "Beet.fixableBeat(Utf8String())", "'\(type)' maps to '\(serde)' serde")
        }
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.usedFixableSerde, "did not use fixable serde")
    }
    
    // -----------------
    // Enums Scalar
    // -----------------
    func testTypeMapperEnumsScalar() {
        let tm = TypeMapper()
        let type: IdlType = .idlTypeEnum(IdlTypeScalarEnum(variants: [
            IdlEnumVariant(name: "Wallet", fields: nil),
            IdlEnumVariant(name: "Token", fields: nil),
            IdlEnumVariant(name: "NFT", fields: nil)
        ]))
        tm.clearUsages()
        let ty = tm.map(ty: type, name: "MembershipModel")
        XCTAssert(ty == "MembershipModel", "name as type")
        XCTAssert(tm.serdePackagesUsed.count == 0, "no serdePackagesUsed")
        let scalarEnumsUsed: Dictionary<String, [String]> = ["MembershipModel": ["Wallet", "Token", "NFT"]]
        XCTAssert(tm.scalarEnumsUsed == scalarEnumsUsed)
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type, name: "MembershipModel")
        XCTAssert(serde == "FixedSizeBeet(value: .scalar( FixedScalarEnum<MembershipModel>() ))", "serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.scalarEnumsUsed == scalarEnumsUsed)
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
    }
    
    // -----------------
    // Composites Option
    // -----------------
    func testTypeMapperOptionNumber() {
        let tm = TypeMapper()
        let type: IdlType = .idlTypeOption(.init(option: .beetTypeMapKey(.numbersTypeMapKey(.u16))))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "COption<UInt16>", "option<u16>")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixableBeat(coption(inner: Beet.fixedBeet(.init(value: .scalar(u16())))))", "option<u16> serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
    }
    
    func testTypeMapperOptionBigNumber() {
        let tm = TypeMapper()
        let type: IdlType = .idlTypeOption(.init(option: .beetTypeMapKey(.numbersTypeMapKey(.u256))))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "COption<UInt256>", "option<u256>")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixableBeat(coption(inner: Beet.fixedBeet(.init(value: .scalar(u256())))))", "option<u256> serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
        
    }
    
    // -----------------
    // Composites Vec
    // -----------------
    func testTypeMapperVecNumber() {
        let tm = TypeMapper()
        let type: IdlType = .idlTypeVec(.init(vec: .beetTypeMapKey(.numbersTypeMapKey(.u16))))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "[UInt16]", "vec<u16>")
        XCTAssert(tm.serdePackagesUsed.count == 0, "no serdePackagesUsed")
        
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixableBeat(array(element: Beet.fixedBeet(.init(value: .scalar(u16())))))", "vec<u16> serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
    }
    
    func testTypeMapperVecBigNumber() {
        let tm = TypeMapper()
        let type: IdlType = .idlTypeVec(.init(vec: .beetTypeMapKey(.numbersTypeMapKey(.u256))))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "[UInt256]", "vec<u256>")
        XCTAssert(tm.serdePackagesUsed.count == 0, "no serdePackagesUsed")
        
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixableBeat(array(element: Beet.fixedBeet(.init(value: .scalar(u256())))))", "vec<u256> serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
    }
    
    // -----------------
    // Composites Sized Array
    // -----------------
    func testTypeMapperArrayNumber() {
        let tm = TypeMapper()
        let type: IdlType = .idlTypeArray(IdlTypeArray(array: [IdlTypeArrayInner(idlType: .beetTypeMapKey(.numbersTypeMapKey(.u16)), size: 4)]))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "[UInt16] /* size: 4 */", "array<u16>")
        XCTAssert(tm.serdePackagesUsed.count == 0, "no serdePackagesUsed")
        
        tm.clearUsages()

        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixedBeet(.init(value: .collection(UniformFixedSizeArray<UInt16>(element: .init(value: .scalar(u16())), len: 4))))", "array<u16> serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
        XCTAssert(!tm.usedFixableSerde, "did not use fixable serde")
    }
    
    // -----------------
    // Composites User Defined
    // -----------------
    func testTypeMapperCompositeUserDefined() {
        let tm = TypeMapper(customTypesPaths: ["ConfigData": "/module/of/config-data.swift"])
        let type: IdlType = .idlTypeDefined(.init(defined: "ConfigData"))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "ConfigData")
        XCTAssert(tm.serdePackagesUsed.count == 0, "no serdePackages used")
        
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "configDataBeetWrapped")
        XCTAssert(tm.serdePackagesUsed.count == 0, "no serdePackages used")
        let expectedImports: Dictionary<String, Set<String>> = ["/module/of/config-data.swift": Set(["configDataBeet"])]
        XCTAssert(tm.localImportsByPath == expectedImports)
        XCTAssert(!tm.usedFixableSerde, "did not use fixable serde")
    }
    
    func testTypeMapperExtensionPublicKey() {
        let tm = TypeMapper()
        let type: IdlType = .publicKey(.keysTypeMapKey(.publicKey))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "PublicKey", "publicKey")
        XCTAssert(tm.serdePackagesUsed.contains(.SOLANA_WEB3_PACKAGE))
        
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixedBeet(.init(value: .scalar(BeetPublicKey())))", "publicKey serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_SOLANA_PACKAGE))
        XCTAssert(!tm.usedFixableSerde, "did not use fixable serde")
    }
    
    // -----------------
    // Composites Multilevel
    // -----------------
    func testTypeMapperCompositeExtensionPublicKey() {
        let tm = TypeMapper()
        let type: IdlType = .idlTypeOption(.init(option: .publicKey(.keysTypeMapKey(.publicKey))))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "COption<PublicKey>", "option<publicKey>")
        XCTAssert(tm.serdePackagesUsed.contains(.SOLANA_WEB3_PACKAGE))
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixableBeat(coption(inner: Beet.fixedBeet(.init(value: .scalar(BeetPublicKey())))))", "publicKey serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_SOLANA_PACKAGE))
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.localImportsByPath.count == 0, "no localImports used")
        
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
    }
    
    func testTypeMapperCompositeOptionOptionNumber() {
        let tm = TypeMapper()
        let type: IdlType = .idlTypeOption(.init(option: .idlTypeOption(.init(option: .beetTypeMapKey(.numbersTypeMapKey(.u64))))))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "COption<COption<UInt64>>", "option<option<u64>>")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixableBeat(coption(inner: Beet.fixableBeat(coption(inner: Beet.fixedBeet(.init(value: .scalar(u64())))))))", "publicKey serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.localImportsByPath.count == 0, "no localImports used")
        
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
    }
    
    func testTypeMapperCompositeOptionOptionPublicKey() {
        let tm = TypeMapper()
        let type: IdlType = .idlTypeOption(.init(option: .idlTypeOption(.init(option: .publicKey(.keysTypeMapKey(.publicKey))))))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "COption<COption<PublicKey>>", "option<option<publicKey>>")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.serdePackagesUsed.contains(.SOLANA_WEB3_PACKAGE))
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixableBeat(coption(inner: Beet.fixableBeat(coption(inner: Beet.fixedBeet(.init(value: .scalar(BeetPublicKey())))))))", "publicKey serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_SOLANA_PACKAGE))
        XCTAssert(tm.localImportsByPath.count == 0, "no localImports used")
        
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
    }
    
    func testTypeMapperCompositeTypesMultinivelVecOptionConfigData() {
        let tm = TypeMapper(customTypesPaths: ["ConfigData": "/module/of/config-data.swift"])
        let type: IdlType = .idlTypeVec(.init(vec: .idlTypeOption(.init(option: .idlTypeDefined(.init(defined: "ConfigData"))))))
        
        let ty = tm.map(ty: type)
        XCTAssert(ty == "[COption<ConfigData>]", "option<option<publicKey>>")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        let expectedImports: Dictionary<String, Set<String>> = ["/module/of/config-data.swift": Set(["ConfigData"])]
        XCTAssert(tm.localImportsByPath == expectedImports)
        tm.clearUsages()
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixableBeat(array(element: Beet.fixableBeat(coption(inner: configDataBeetWrapped))))", "publicKey serde")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        let expectedImports2: Dictionary<String, Set<String>> = ["/module/of/config-data.swift": Set(["configDataBeet"])]
        XCTAssert(tm.localImportsByPath == expectedImports2)
        
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
    }
    
    // -----------------
    // Map Serde Fields
    // -----------------
    func testTypeMapperSerdeFields() {
        let u16 = IdlField(name: "u16", type: .beetTypeMapKey(.numbersTypeMapKey(.u16)), attrs: nil)
        let tm = TypeMapper(customTypesPaths: ["ConfigData": "/module/of/config-data.swift"])
        tm.clearUsages()
        
        let mappedFields = tm.mapSerdeFields(fields: [u16])
        
        XCTAssert(mappedFields == [TypeMappedSerdeField(name: "u16", type: "Beet.fixedBeet(.init(value: .scalar(u16())))")])
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(!tm.usedFixableSerde, "did not use fixable serde")
        tm.clearUsages()
    }
    
    func testTypeMapperSerdeFields2() {
        let optionPublicKey = IdlField(name: "optionPublicKey", type: .idlTypeOption(.init(option: .publicKey(.keysTypeMapKey(.publicKey)))), attrs: nil)
        let tm = TypeMapper(customTypesPaths: ["ConfigData": "/module/of/config-data.swift"])
        tm.clearUsages()
        
        let mappedFields2 = tm.mapSerdeFields(fields: [optionPublicKey])
        XCTAssert(mappedFields2 == [TypeMappedSerdeField(name: "optionPublicKey", type: "Beet.fixableBeat(coption(inner: Beet.fixedBeet(.init(value: .scalar(BeetPublicKey())))))")])
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_SOLANA_PACKAGE))
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
        tm.clearUsages()
    }
    
    func testTypeMapperSerdeFields3() {
        let u16 = IdlField(name: "u16", type: .beetTypeMapKey(.numbersTypeMapKey(.u16)), attrs: nil)
        let configData = IdlField(name: "configData", type: .idlTypeDefined(.init(defined: "ConfigData")), attrs: nil)
        let optionPublicKey = IdlField(name: "optionPublicKey", type: .idlTypeOption(.init(option: .publicKey(.keysTypeMapKey(.publicKey)))), attrs: nil)
        let vecOptionConfigData = IdlField(name: "vecOptionConfigData", type: .idlTypeVec(.init(vec: .idlTypeOption(.init(option: .idlTypeDefined(.init(defined: "ConfigData")))))), attrs: nil)
        let tm = TypeMapper(customTypesPaths: ["ConfigData": "/module/of/config-data.swift"])
        tm.clearUsages()
        
        let mappedFields3 = tm.mapSerdeFields(fields: [
            u16,
            optionPublicKey,
            configData,
            vecOptionConfigData,
        ])
        
        XCTAssert(mappedFields3 == [
            TypeMappedSerdeField(name: "u16", type: "Beet.fixedBeet(.init(value: .scalar(u16())))"),
            TypeMappedSerdeField(name: "optionPublicKey", type: "Beet.fixableBeat(coption(inner: Beet.fixedBeet(.init(value: .scalar(BeetPublicKey())))))"),
            TypeMappedSerdeField(name: "configData", type: "configDataBeetWrapped"),
            TypeMappedSerdeField(name: "vecOptionConfigData", type: "Beet.fixableBeat(array(element: Beet.fixableBeat(coption(inner: configDataBeetWrapped))))"),
        ])
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_SOLANA_PACKAGE))
        let expectedImports: Dictionary<String, Set<String>> = ["/module/of/config-data.swift": Set(["configDataBeet"])]
        XCTAssert(tm.localImportsByPath == expectedImports)
        XCTAssert(tm.usedFixableSerde, "used fixable serde")
    }
    
    // -----------------
    // Imports
    // -----------------
    func testTypeMapperImportsForSerdePackagesUsed() {
        let tm = TypeMapper()
        tm.clearUsages()
        
        let packsUsed = [
            SerdePackage.SOLANA_WEB3_PACKAGE,
            SerdePackage.BEET_PACKAGE,
            SerdePackage.BEET_SOLANA_PACKAGE
        ]
        
        for pack in packsUsed {
            tm.serdePackagesUsed.insert(pack)
        }
        let imports = tm.importsUsed(fileDir: SOME_FILE_DIR, forcePackages: nil)
        XCTAssert(imports.contains("import Solana"))
        XCTAssert(imports.contains("import Beet"))
        XCTAssert(imports.contains("import BeetSolana"))
        
        tm.clearUsages()
        
    }
    
    func testTypeMapperImportsForSerdePackagesUsed2() {
        let tm = TypeMapper()
        tm.clearUsages()
        
        let packsUsed2 = [
            SerdePackage.BEET_PACKAGE
        ]
        for pack in packsUsed2 {
            tm.serdePackagesUsed.insert(pack)
        }
        let imports2 = tm.importsUsed(fileDir: SOME_FILE_DIR, forcePackages: nil)
        XCTAssert(imports2.contains("import Beet"))
    }
    
    // -----------------
    // Type Aliases
    // -----------------
    func testTypeMapperUserDefinedAliased() {
        let tm = TypeMapper(typeAliases: ["UnixTimestamp": "i64"])
        let type: IdlType = .idlTypeDefined(IdlTypeDefined(defined: "UnixTimestamp"))
        let ty = tm.map(ty: type)
        XCTAssert(ty == "Int64")
        
        let serde = tm.mapSerde(ty: type)
        XCTAssert(serde == "Beet.fixedBeet(.init(value: .scalar(i64())))")
        XCTAssert(tm.serdePackagesUsed.contains(.BEET_PACKAGE))
        XCTAssert(!tm.usedFixableSerde,"did not use fixable serde")
        XCTAssert(tm.localImportsByPath.count == 0, "used no local imports")
    }
}
