import XCTest
@testable import Solita
import PathKit

final class SolitaTests: XCTestCase {
    fileprivate func getDencoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    func testSerumMultisig() {
        let json = TestDataProvider.serumMultisigJson
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
    
    func testActionHouse() {
        let json = TestDataProvider.auctionHouseJson
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
    
    func testCandyMachine() {
        let json = TestDataProvider.candyMachineJson
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
    
    func testFanout() {
        let json = TestDataProvider.fanoutJson
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
    
    func testDataEnum() {
        let json = TestDataProvider.featDataEnum
        let idl = try! getDencoder().decode(Idl.self, from: json)
        Solita(idl: idl).renderAndWriteTo(outputDir: Path.current.string)
    }
}
