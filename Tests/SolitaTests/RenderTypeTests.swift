import XCTest
@testable import Solita
import PathKit

let DIAGNOSTIC_ON = true

let TYPE_FILE_DIR = Path("/root/app/instructions/")
struct Opts {
    let logImports: Bool
    let logCode: Bool
    let logBuild: Bool
}

func checkRenderedType(ty: IdlDefinedTypeDefinition,
                       imports: [SerdePackage],
                       opts: Opts = Opts(logImports: DIAGNOSTIC_ON, logCode: DIAGNOSTIC_ON, logBuild: DIAGNOSTIC_ON)
){
    let swift = renderType(
        ty: ty,
        fullFileDir: TYPE_FILE_DIR,
        accountFilesByType: [:],
        customFilesByType: ["Creator": "/module/of/creator.swift"],
        typeAliases: [:],
        forceFixable: FORCE_FIXABLE_NEVER
    )
    if opts.logCode { print("--------- <Swift> --------\n\(swift.code)\n--------- </Swift> --------\n") }
    verifySyntacticCorrectness(swift: swift.code)
    let analized = analyzeCode(swift: swift.code)
    XCTAssert(analized.output.last!.contains("Build complete!"))
}

final class RenderTypeTests: XCTestCase {
    func testTypesWithOneFieldNotUsingLibTypes() {
        let ty = IdlDefinedTypeDefinition(name: "CandyMachineData",
                                          type: .idlDefinedType(.init(kind: .struct, fields: [
                                            .init(name: "uuid", type: .beetTypeMapKey(.stringTypeMapKey(.string)), attrs: nil)
                                          ])))
        
        checkRenderedType(ty: ty, imports: [.BEET_PACKAGE])
    }
    
    func testWithOneFieldNotUsingLibTypes() {
        let ty = IdlDefinedTypeDefinition(name: "CandyMachineData",
                                          type: .idlDefinedType(.init(kind: .struct, fields: [
                                            .init(name: "uuid", type: .beetTypeMapKey(.stringTypeMapKey(.string)), attrs: nil),
                                            .init(name: "itemsAvailable", type: .beetTypeMapKey(.numbersTypeMapKey(.u64)), attrs: nil),
                                            .init(name: "goLiveDate", type: .beetTypeMapKey(.numbersTypeMapKey(.i64)), attrs: nil)
                                          ])))
        
        checkRenderedType(ty: ty, imports: [.BEET_PACKAGE])
    }
    
    func testTypesWithFourFieldsOneReferringToOtherDefinedType() {
        let ty = IdlDefinedTypeDefinition(name: "CandyMachineData",
                                          type: .idlDefinedType(.init(kind: .struct, fields: [
                                            .init(name: "uuid", type: .beetTypeMapKey(.stringTypeMapKey(.string)), attrs: nil),
                                            .init(name: "creators", type: .idlTypeVec(.init(vec: .idlTypeDefined(.init(defined: "Creator")))), attrs: nil),
                                            .init(name: "maxSupply", type: .beetTypeMapKey(.numbersTypeMapKey(.u64)), attrs: nil),
                                            .init(name: "isMutable", type: .beetTypeMapKey(.numbersTypeMapKey(.bool)), attrs: nil)
                                          ])))
        
        let swift = renderType(
            ty: ty,
            fullFileDir: TYPE_FILE_DIR,
            accountFilesByType: [:],
            customFilesByType: ["Creator": "Creator"],
            typeAliases: [:],
            forceFixable: FORCE_FIXABLE_NEVER
        )
        print("--------- <Swift> --------\n\(swift.code)\n--------- </Swift> --------\n")
        XCTAssert(swift.code.contains("let creators: [Creator]"))
        XCTAssert(swift.code.contains("import Creator"))
        XCTAssert(swift.code.contains("Beet.fixableBeat(array(element: creatorBeet))"))
    }
    
    func testTypeEnumWithInlineData() {
        let ty = IdlDefinedTypeDefinition(name: "CollectionInfo", type: .idlTypeDataEnum(.init(variants: [
            .init(name: "V1", fields: [
                .init(name: "symbol", type: .beetTypeMapKey(.stringTypeMapKey(.string)), attrs: nil),
                .init(name: "verified_creators", type: .publicKey(.keysTypeMapKey(.publicKey)), attrs: nil),
                .init(name: "whitelist_root", type: .idlTypeArray(.init(array: [IdlTypeArrayInner(idlType: .beetTypeMapKey(.numbersTypeMapKey(.u8)), size: 2)])), attrs: nil)
            ]),
            .init(name: "V2", fields: [
                .init(name: "collection_mint", type: .publicKey(.keysTypeMapKey(.publicKey)), attrs: nil)
            ])
        ])))
        checkRenderedType(ty: ty, imports: [.BEET_PACKAGE], opts: Opts(logImports: DIAGNOSTIC_ON, logCode: DIAGNOSTIC_ON, logBuild: true))
    }
}
