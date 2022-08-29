import XCTest
@testable import Solita
import PathKit

let ROOT_DIR = "/tmp/root"
let ACCOUNT_FILE_DIR = Path("\(ROOT_DIR)/src/generated/accounts/account-uno.ts")

struct CheckRenderedAccountOpts {
    let logImports: Bool?
    let logCode: Bool?
    let serializers: CustomSerializers?
    let hasImplicitDiscriminator: Bool?
    let verifyBuild: Bool?
}

func checkRenderedAccount(
    account: IdlAccount,
    imports: [SerdePackage],
    opts:CheckRenderedAccountOpts=CheckRenderedAccountOpts(logImports: DIAGNOSTIC_ON, logCode: DIAGNOSTIC_ON, serializers: CustomSerializers.empty(), hasImplicitDiscriminator: nil, verifyBuild: true)
) {
    let swift = renderAccount(
        account: account,
        fullFileDir: ACCOUNT_FILE_DIR,
        accountFilesByType: [:],
        customFilesByType: [:],
        typeAliases: [:],
        serializers: opts.serializers!,
        forceFixable: FORCE_FIXABLE_NEVER,
        programId: PROGRAM_ID,
        resolveFieldType: { typeName in nil },
        hasImplicitDiscriminator: opts.hasImplicitDiscriminator ?? true
    )
    
    if opts.logCode == true {
        print(
            "--------- <Swift> --------\n\(swift)\n--------- </Swift> --------"
        )
    }
    verifySyntacticCorrectness(swift: swift)
    if opts.verifyBuild == true {
        let analyzed = analyzeCode(swift: swift)
        XCTAssert(analyzed.output.last!.contains("Build complete!"))
    }
}

final class RenderAccountsTests: XCTestCase {
    
    func testAccountsNoField() {
        let ix = IdlAccount(name: "AuctionHouse", type: .init(kind: .struct, fields: []))
        checkRenderedAccount(account: ix, imports: [], opts: CheckRenderedAccountOpts(
            logImports: DIAGNOSTIC_ON,
            logCode: true,
            serializers: CustomSerializers.empty(),
            hasImplicitDiscriminator: nil,
            verifyBuild: true)
        )
    }
    func testAccountsOneField() {
        let ix = IdlAccount(name: "AuctionHouse", type: .init(kind: .struct, fields: [.init(name: "auctionHouseFeeAccount", type: .publicKey(.keysTypeMapKey(.publicKey)), attrs: nil)]))
        checkRenderedAccount(account: ix, imports: [], opts: CheckRenderedAccountOpts(
            logImports: DIAGNOSTIC_ON,
            logCode: true,
            serializers: CustomSerializers.empty(),
            hasImplicitDiscriminator: nil,
            verifyBuild: true)
        )
    }
    func testAccountsFourField() {
        let ix = IdlAccount(name: "AuctionHouse", type: .init(kind: .struct, fields: [
            .init(name: "auctionHouseFeeAccount", type: .publicKey(.keysTypeMapKey(.publicKey)), attrs: nil),
            .init(name: "feePayerBump", type: .beetTypeMapKey(.numbersTypeMapKey(.u8)), attrs: nil),
            .init(name: "sellerFeeBasisPoints", type: .beetTypeMapKey(.numbersTypeMapKey(.u16)), attrs: nil),
            .init(name: "requiresSignOff", type: .beetTypeMapKey(.numbersTypeMapKey(.bool)), attrs: nil)
        ]))
        checkRenderedAccount(account: ix, imports: [], opts: CheckRenderedAccountOpts(
            logImports: DIAGNOSTIC_ON,
            logCode: true,
            serializers: CustomSerializers.empty(),
            hasImplicitDiscriminator: nil,
            verifyBuild: true)
        )
    }
    
    func testAccountsPrettyFunctionForDifferentTypes() {
        let ix = IdlAccount(name: "AuctionHouse", type: .init(kind: .struct, fields: [
            .init(name: "auctionHouseFeeAccount", type: .publicKey(.keysTypeMapKey(.publicKey)), attrs: nil),
            .init(name: "feePayerBump", type: .beetTypeMapKey(.numbersTypeMapKey(.u8)), attrs: nil),
            .init(name: "someLargeNumber", type: .beetTypeMapKey(.numbersTypeMapKey(.u64)), attrs: nil)
        ]))
        checkRenderedAccount(account: ix, imports: [], opts: CheckRenderedAccountOpts(
            logImports: DIAGNOSTIC_ON,
            logCode: true,
            serializers: CustomSerializers.empty(),
            hasImplicitDiscriminator: nil,
            verifyBuild: true)
        )
    }
    
    func testAccountsOneFieldWithCustomSerializers() {
        let ix = IdlAccount(name: "AuctionHouse", type: .init(kind: .struct, fields: [
            .init(name: "auctionHouseFeeAccount", type: .publicKey(.keysTypeMapKey(.publicKey)), attrs: nil)
        ]))
        try! Path("/tmp/root/src/custom/serializer").mkpath()
        let serializers = CustomSerializers.create(projectRoot: ROOT_DIR, serializers: ["AuctionHouse": "src/custom/serializer"])
        
        checkRenderedAccount(account: ix,
                             imports: [],
                             opts: CheckRenderedAccountOpts(
                                logImports: DIAGNOSTIC_ON,
                                logCode: true,
                                serializers: serializers,
                                hasImplicitDiscriminator: nil,
                                verifyBuild: false)
        )
    }
    
    // -----------------
    // Padding
    // -----------------
    func testAccountsOneAccountWithTwoFieldsOneHasPaddingAttr() {
        let ix = IdlAccount(name: "StructAccountWithPadding", type: .init(kind: .struct, fields: [
            .init(name: "count", type: .beetTypeMapKey(.numbersTypeMapKey(.u8)), attrs: nil),
            .init(name: "padding", type: .idlTypeArray(.init(array: [.init(idlType: .beetTypeMapKey(.numbersTypeMapKey(.u8)), size: 3)])), attrs: ["padding"])
        ]))
        checkRenderedAccount(account: ix, imports: [], opts: CheckRenderedAccountOpts(
            logImports: DIAGNOSTIC_ON,
            logCode: true,
            serializers: CustomSerializers.empty(),
            hasImplicitDiscriminator: nil,
            verifyBuild: true)
        )
    }
    
    func testAccountsOneAccountWithOutDiscriminatorWithTwoFieldsOneHasPaddingAttr() {
        let ix = IdlAccount(name: "StructAccountWithPadding", type: .init(kind: .struct, fields: [
            .init(name: "count", type: .beetTypeMapKey(.numbersTypeMapKey(.u8)), attrs: nil),
            .init(name: "padding", type: .idlTypeArray(.init(array: [.init(idlType: .beetTypeMapKey(.numbersTypeMapKey(.u8)), size: 3)])), attrs: ["padding"])
        ]))
        checkRenderedAccount(account: ix, imports: [], opts: CheckRenderedAccountOpts(
            logImports: DIAGNOSTIC_ON,
            logCode: true,
            serializers: CustomSerializers.empty(),
            hasImplicitDiscriminator: false,
            verifyBuild: true)
        )
    }
    
    func testAccountsOneAccountWithThreeFieldsMiddleOneHasPaddingAttr() {
        let ix = IdlAccount(name: "StructAccountWithPadding", type: .init(kind: .struct, fields: [
            .init(name: "count", type: .beetTypeMapKey(.numbersTypeMapKey(.u8)), attrs: nil),
            .init(name: "padding", type: .idlTypeArray(.init(array: [.init(idlType: .beetTypeMapKey(.numbersTypeMapKey(.u8)), size: 3)])), attrs: ["padding"]),
            .init(name: "largerCount", type: .beetTypeMapKey(.numbersTypeMapKey(.u64)), attrs: nil),
        ]))
        checkRenderedAccount(account: ix, imports: [], opts: CheckRenderedAccountOpts(
            logImports: DIAGNOSTIC_ON,
            logCode: true,
            serializers: CustomSerializers.empty(),
            hasImplicitDiscriminator: nil,
            verifyBuild: true)
        )
    }
    
    func testAccountsOneAccountWithThreeFieldsMiddleOneHasPaddingAttrWithoutImplicitDiscriminator() {
        let ix = IdlAccount(name: "StructAccountWithPadding", type: .init(kind: .struct, fields: [
            .init(name: "count", type: .beetTypeMapKey(.numbersTypeMapKey(.u8)), attrs: nil),
            .init(name: "padding", type: .idlTypeArray(.init(array: [.init(idlType: .beetTypeMapKey(.numbersTypeMapKey(.u8)), size: 3)])), attrs: ["padding"]),
            .init(name: "largerCount", type: .beetTypeMapKey(.numbersTypeMapKey(.u64)), attrs: nil),
        ]))
        checkRenderedAccount(account: ix, imports: [], opts: CheckRenderedAccountOpts(
            logImports: DIAGNOSTIC_ON,
            logCode: true,
            serializers: CustomSerializers.empty(),
            hasImplicitDiscriminator: false,
            verifyBuild: true)
        )
    }
}
