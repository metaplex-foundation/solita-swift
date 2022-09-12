import XCTest
@testable import Solita
import PathKit

final class SolitaTests: XCTestCase {
    fileprivate func getDencoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    func testSerumMultisig() {
        let json = stubbedResponse("serum_multisig")
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
    
    func testActionHouse() {
        let json = stubbedResponse("action_house")
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
    
    func testCandyMachine() {
        let json = stubbedResponse("candy_machine")
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
    
    func testFanout() {
        let json = stubbedResponse("fanout")
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
    
    func testDataEnum() {
        let json = stubbedResponse("feat-data-enum")
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
}
