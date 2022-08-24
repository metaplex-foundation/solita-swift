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
    ops: Ops=Ops(logImports: DIAGNOSTIC_ON, logCode: DIAGNOSTIC_ON, verify: true, lineNumbers: false)
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
        XCTAssert(analyzed.output.last!.contains("Build complete!"))
    }
}

final class RenderInstructionTests: XCTestCase {
    
    func testIxEmptyArgs() {
        let ix = IdlInstruction(name: "empyArgs", accounts: [
            IdlInstructionAccount(name: "authority", isMut: false, isSigner: true, desc: nil, optional: nil)
        ], args: [])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
    
    func testIxEmptyArgEmptyAccounts() {
        let ix = IdlInstruction(name: "empyArgs", accounts: [], args: [])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
    
    func testIxOneArg() {
        let ix = IdlInstruction(name: "oneArg", accounts: [
            IdlInstructionAccount(name: "authority", isMut: false, isSigner: true, desc: nil, optional: nil)
        ], args: [.init(name: "amount", type: .beetTypeMapKey(.numbersTypeMapKey(.u64)), attrs: nil)])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
    
    func testIxTwoArgs() {
        let ix = IdlInstruction(name: "twoArg", accounts: [
            IdlInstructionAccount(name: "authority", isMut: false, isSigner: true, desc: nil, optional: nil)
        ], args: [
            .init(name: "amount", type: .beetTypeMapKey(.numbersTypeMapKey(.u64)), attrs: nil),
            .init(name: "authority", type: .publicKey(.keysTypeMapKey(.publicKey)), attrs: nil),
        ])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
    
    func testIxTwoAccountsAndTwoArgs() {
        let ix = IdlInstruction(name: "twoArg", accounts: [
            IdlInstructionAccount(name: "authority", isMut: false, isSigner: true, desc: nil, optional: nil),
            IdlInstructionAccount(name: "feeWithdrawalDestination", isMut: true, isSigner: false, desc: nil, optional: nil)
        ], args: [
            .init(name: "amount", type: .beetTypeMapKey(.numbersTypeMapKey(.u64)), attrs: nil),
            .init(name: "authority", type: .publicKey(.keysTypeMapKey(.publicKey)), attrs: nil),
        ])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
    
    func testIxThreeAccountsTwoOptionals() {
        let ix = IdlInstruction(name: "choicy", accounts: [
            IdlInstructionAccount(name: "authority", isMut: false, isSigner: true, desc: nil, optional: nil),
            IdlInstructionAccount(name: "useAuthorityRecord", isMut: true, isSigner: false, desc: "Use Authority Record PDA If present the program Assumes a delegated use authority", optional: true),
            IdlInstructionAccount(name: "burner", isMut: false, isSigner: false, desc: "Program As Signer (Burner)", optional: true)
        ], args: [])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
    
    func testIxAccountsRenderCommentsWithAndWithoutDesc() {
        let ix = IdlInstruction(name: "choicy", accounts: [
            IdlInstructionAccount(name: "withoutDesc", isMut: false, isSigner: true, desc: nil, optional: nil),
            IdlInstructionAccount(name: "withDesc", isMut: true, isSigner: false, desc: "Use Authority Record PDA If present the program Assumes a delegated use authority", optional: true),
        ], args: [])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
    
    func testIxEmptyArgsOneSystemProgramAccount() {
        let ix = IdlInstruction(name: "empyArgsWithSystemProgram", accounts: [
            IdlInstructionAccount(name: "authority", isMut: false, isSigner: true, desc: nil, optional: nil),
            IdlInstructionAccount(name: "systemProgram", isMut: false, isSigner: false, desc: nil, optional: nil),
        ], args: [])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
    
    func testIxWithArgsOneSystemProgramAccountAndProgramId() {
        let ix = IdlInstruction(name: "empyArgsWithSystemProgram", accounts: [
            IdlInstructionAccount(name: "authority", isMut: false, isSigner: true, desc: nil, optional: nil),
            IdlInstructionAccount(name: "systemProgram", isMut: false, isSigner: false, desc: nil, optional: nil),
            IdlInstructionAccount(name: "programId", isMut: false, isSigner: false, desc: nil, optional: nil),
        ], args: [])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
    
    func testIxEmptyArgsOneSystemProgramAccountOneOptionalRentAccount() {
        let ix = IdlInstruction(name: "empyArgsWithSystemProgram", accounts: [
            IdlInstructionAccount(name: "authority", isMut: false, isSigner: true, desc: nil, optional: nil),
            IdlInstructionAccount(name: "systemProgram", isMut: false, isSigner: false, desc: nil, optional: nil),
            IdlInstructionAccount(name: "rent", isMut: false, isSigner: false, desc: nil, optional: true),
        ], args: [])
        checkRenderedIx(ix: ix, imports: [.BEET_PACKAGE, .SOLANA_WEB3_PACKAGE])
    }
}
