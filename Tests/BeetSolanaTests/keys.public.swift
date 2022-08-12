import Foundation
import XCTest
@testable import BeetSolana
import Solana
import Beet

func checkCases<U: Equatable>(
    offsets: [Int],
    cases: [U],
    beet: FixedSizeBeet
) {
    for offset in offsets {
        for x in cases {
            print("Input: \(x)")
            print("Offset: \(offset)")
            
            let byteSize: UInt
            
            switch beet.value {
            case .scalar(let type):
                byteSize = type.byteSize
            case .collection(let type):
                byteSize = type.byteSize
            }
        
            var buf = Data(count: offset + Int(byteSize) + offset)

            switch beet.value {
            case .scalar(let type):
                type.write(buf: &buf, offset: offset, value: x)
            case .collection(let type):
                type.write(buf: &buf, offset: offset, value: x)
            }
            
            print("Buff: \(buf)")
            
            var n: U
            switch beet.value {
            case .scalar(let type):
                n = type.read(buf: buf, offset: offset)
            case .collection(let type):
                n = type.read(buf: buf, offset: offset)
            }
            print("N: \(n)")
            XCTAssertEqual(x, n)
        }
    }
}

final class collectionArrayTests: XCTestCase {
    func testPublicKeyRoundtrip() {
        let cases: [PublicKey] = [
            PublicKey.default,
            PublicKey(string: "p1exdMJcjVao65QdewkaZRUnU6VPSXhus9n2GzWfh98")!
        ]
        let offsets: [Int] = [0, 4, 20]
        let beet = FixedSizeBeet(value: .scalar(BeetPublicKey()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
}
