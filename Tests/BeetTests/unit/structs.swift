import Foundation
import XCTest
@testable import Beet
import Solana

struct GameScore: Equatable {
    let win: UInt8
    let totalWin: UInt16
    let whaleAccount: UInt128
    let losses: Int32
    
    static let `struct` = BeetStruct(
        fields: [
            ("win", FixedSizeBeet(value: .scalar(u8()))),
            ("totalWin", FixedSizeBeet(value:.scalar(u16()))),
            ("whaleAccount", FixedSizeBeet(value: .scalar(u128()))),
            ("losses", FixedSizeBeet(value: .scalar(i32())))
        ],
        construct: { args in
            GameScore(
                win: args["win"] as! UInt8,
                totalWin: args["totalWin"] as! UInt16,
                whaleAccount: args["whaleAccount"] as! UInt128,
                losses: args["losses"] as! Int32
            )
        },
        description: "GameStruct"
    )
}

let gs1 = GameScore(
    win: 1,
    totalWin: 100,
    whaleAccount: UInt128("340282366920938463463374607431768211451"),
    losses: -234
)

let gs2 = GameScore(
    win: 10,
    totalWin: 200,
    whaleAccount: UInt128("340282366920938463463374607431768211400"),
    losses: -500
)


final class structsTests: XCTestCase {
    
    func testStructStaticProperties() {
        XCTAssertEqual(GameScore.struct.byteSize, 23)
    }
    
    func testStructRoundtripOneNumberOnlyStruct() {
        let (buf, _) = GameScore.struct.serialize(instance: gs1)
        let (deserialized, offset) = GameScore.struct.deserialize(buffer: buf)
        XCTAssertEqual(UInt(offset), GameScore.struct.byteSize)
        XCTAssertEqual(gs1, deserialized)
    }
    
    func testStructRoundtripTwoNumbersOnlyStructs() {
        let buf = GameScore.struct.serialize(instance: gs1).0 + GameScore.struct.serialize(instance: gs2).0
        let (first, firstOffset) = GameScore.struct.deserialize(buffer: buf)
        let (second, secondOffset) = GameScore.struct.deserialize(buffer: buf, offset: firstOffset)
        
        XCTAssertEqual(UInt(firstOffset), GameScore.struct.byteSize)
        XCTAssertEqual(UInt(secondOffset), GameScore.struct.byteSize * 2)
        XCTAssertEqual(gs1, first)
        XCTAssertEqual(gs2, second)
        
    }
}
