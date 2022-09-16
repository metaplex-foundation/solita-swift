import Foundation
import XCTest
@testable import Beet

struct Results: Equatable {
    let win: UInt8
    let totalWin: UInt16
    let losses: Int32
    
    static let `struct` = BeetStruct(
        fields: [
            ("win", FixedSizeBeet(value: .scalar(u8()))),
            ("totalWin", FixedSizeBeet(value:.scalar(u16()))),
            ("losses", FixedSizeBeet(value: .scalar(i32())))
        ],
        construct: { args in
            Results(
                win: args["win"] as! UInt8,
                totalWin: args["totalWin"] as! UInt16,
                losses: args["losses"] as! Int32
            )
        },
        description: "Results"
    )
}

struct Trader: Equatable {
    let name: String
    let results: Results
    let age: UInt8
    
    static let `struct` = BeetStruct(
        fields: [
            ("name", FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: 4)))),
            ("results", FixedSizeBeet(value:.scalar(Results.struct))),
            ("age", FixedSizeBeet(value: .scalar(u8())))
        ],
        construct: { args in
            Trader(
                name: args["name"] as! String,
                results: args["results"] as! Results,
                age: args["age"] as! UInt8
            )
        },
        description: "Trader"
    )
}


final class structsNestedTests: XCTestCase {
    func testStructRoundtripNestedStruct() {
        let trader = Trader(name: "bob ", results: Results(win: 20, totalWin: 1200, losses: -455), age: 22)
        let extraBytes = [0, 8]
        for extra in extraBytes {
            let (buf,_) = Trader.struct.serialize(instance: trader, byteSize: Int(Trader.struct.byteSize) + extra)
            let (deserialized, offset) = Trader.struct.deserialize(buffer: buf)
            XCTAssertEqual(UInt(offset), Trader.struct.byteSize)
            XCTAssertEqual(deserialized, trader)
        }
    }
}
