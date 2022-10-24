import XCTest
@testable import Solita

final class IdlTests: XCTestCase {
    fileprivate func getDencoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    func testSerumMultisigJsonParsedSuccess() {
        let json = TestDataProvider.serumMultisigJson
        let idl = try! getDencoder().decode(Idl.self, from: json)
        XCTAssertEqual(idl.name, "serum_multisig")
        XCTAssertEqual(idl.instructions.first!.name, "createMultisig")
        XCTAssertEqual(idl.instructions.first!.args.first!.name, "owners")
        XCTAssertEqual(idl.accounts!.first!.name, "Multisig")
        XCTAssertEqual(idl.accounts![1].name, "Transaction")
        if case let .idlTypeVec(typeVec) = idl.instructions.first!.args.first!.type, case .publicKey = typeVec.vec {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
    func testActionHouseJsonParsedSuccess() {
        let json = TestDataProvider.auctionHouseJson
        let idl = try! getDencoder().decode(Idl.self, from: json)
        XCTAssertEqual(idl.instructions.count, 28)
        XCTAssertEqual(idl.accounts!.count, 5)
        XCTAssertEqual(idl.types!.count, 5)
        XCTAssertEqual(idl.errors!.count, 44)
        XCTAssertEqual(idl.name, "auction_house")

    }
    
    func testCandyMachineJsonParsedSuccess() {
        let json = TestDataProvider.candyMachineJson
        let idl = try! getDencoder().decode(Idl.self, from: json)
        XCTAssertEqual(idl.instructions.count, 9)
        XCTAssertEqual(idl.accounts!.count, 2)
        XCTAssertEqual(idl.types!.count, 9)
        XCTAssertEqual(idl.errors!.count, 36)
        XCTAssertEqual(idl.name, "candy_machine")
    }
}
