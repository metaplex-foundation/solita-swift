import XCTest
@testable import Solita
import PathKit

let DIAGNOSTIC_ON = false

let TYPE_FILE_DIR = Path("/root/app/instructions/")
struct Opts {
    let logImports: Bool
    let logCode: Bool
}

func checkRenderedType(ty: IdlDefinedTypeDefinition,
                       imports: [SerdePackage],
                       opts: Opts = Opts(logImports: DIAGNOSTIC_ON, logCode: DIAGNOSTIC_ON)
){
    let swift = renderType(
        ty: ty,
        fullFileDir: TYPE_FILE_DIR,
        accountFilesByType: [:],
        customFilesByType: ["Creator": "/module/of/creator.swift"],
        typeAliases: [:],
        forceFixable: FORCE_FIXABLE_NEVER
    )
    print("--------- <Swift> --------\n\(swift.code)\n--------- </Swift> --------\n")
    verifySyntacticCorrectness(swift: swift.code)
    let analyzed = analyzeCode(swift: swift.code)
}

final class RenderTypeTests: XCTestCase {
    func testTypesWithOneFieldNotUsingLibTypes() {
        let ty = IdlDefinedTypeDefinition(name: "Candy Machine Data",
                                          type: .idlDefinedType(.init(kind: .struct, fields: [
                                            .init(name: "uuid", type: .beetTypeMapKey(.stringTypeMapKey(.string)), attrs: nil)
                                          ])))
        
        checkRenderedType(ty: ty, imports: [.BEET_PACKAGE])
    }
}
