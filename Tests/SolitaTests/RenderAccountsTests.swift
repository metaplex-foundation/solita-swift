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
}

func checkRenderedAccount(
    account: IdlAccount,
    imports: [SerdePackage],
    opts:CheckRenderedAccountOpts=CheckRenderedAccountOpts(logImports: DIAGNOSTIC_ON, logCode: DIAGNOSTIC_ON, serializers: CustomSerializers.empty(), hasImplicitDiscriminator: nil)
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
    let analyzed = analyzeCode(swift: swift)
}

final class RenderAccountsTests: XCTestCase {
    
    func testAccountsNoField() {
        let ix = IdlAccount(name: "AuctionHouse", type: .init(kind: .struct, fields: []))
        checkRenderedAccount(account: ix, imports: [], opts: CheckRenderedAccountOpts(
            logImports: DIAGNOSTIC_ON,
            logCode: true,
            serializers: CustomSerializers.empty(),
            hasImplicitDiscriminator: nil)
        )
    }
}
