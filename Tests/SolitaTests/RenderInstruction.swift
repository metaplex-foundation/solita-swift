import XCTest
@testable import Solita
import PathKit

let PROGRAM_ID = "testprogram"
let INSTRUCTION_FILE_DIR = Path("/root/app/instructions/")

struct Ops {
    let logImports: Bool
    let logCode: Bool
    let verify: Bool
    let lineNumbers: Bool
}

func checkRenderedIx(
    ix: IdlInstruction,
    imports: [SerdePackage],
    ops: Ops=Ops(logImports: DIAGNOSTIC_ON, logCode: DIAGNOSTIC_ON, verify: false, lineNumbers: false)
) {
    let swift = renderInstruction(
        ix: ix,
        fullFileDir: INSTRUCTION_FILE_DIR,
        programId: PROGRAM_ID,
        accountFilesByType: [:],
        customFilesByType: [:],
        typeAliases: [:],
        forceFixable: FORCE_FIXABLE_NEVER
    )
    
    if ops.logCode {
        let renderSw = ops.lineNumbers ? swift.split(separator: "\n").indices
            .map{
                let x = swift.split(separator: "\n")[$0]
                return "\($0 + 1): \(x)"
            }.joined(separator: "\n")
        : swift
        print("--------- <Swift> --------\n\(renderSw)\n--------- </Swift> --------")
    }
    
    if ops.verify {
        verifySyntacticCorrectness(swift: swift)
        let analyzed = analyzeCode(swift: swift)
    }
}

final class RenderInstructionTests: XCTestCase {
    
    func testIxEmptyArgs() {
        let ix = IdlInstruction(name: "empyArgs", accounts: [
            IdlInstructionAccount(name: "authority", isMut: false, isSigner: true, desc: nil, optional: nil)
        ], args: [])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
}
