import XCTest
@testable import Solita

final class IdlTests: XCTestCase {
    fileprivate func getDencoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    func testJsonParsedSuccess() {
        let json = stubbedResponse("serum_multisig")
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
    
    func testXXXX() {
        let json = stubbedResponse("serum_multisig")
        let idl = try! getDencoder().decode(Idl.self, from: json)
        let multisig = idl.accounts!.first!
    }
}

func stubbedResponse(_ filename: String) -> Data {
    @objc class FeelitTests: NSObject { }
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let resourceURL = thisDirectory.appendingPathComponent("Resources/\(filename).json")
    return try! Data(contentsOf: resourceURL)
}
