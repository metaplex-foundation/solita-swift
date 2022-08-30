import XCTest
@testable import Solita
import PathKit

final class SolitaTests: XCTestCase {
    fileprivate func getDencoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    func testExample() async {
        let json = stubbedResponse("serum_multisig")
        let idl = try! getDencoder().decode(Idl.self, from: json)
        await Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
}
