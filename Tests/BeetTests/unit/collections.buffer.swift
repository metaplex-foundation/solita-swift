import Foundation
import XCTest
@testable import Beet
import Solana

final class collectionBufferTests: XCTestCase {
    func testCollectionsFixedSizeBuffer() {
        let cases: [Data] = [
            "abc *def😁".data(using: .utf8)! ,
            "aaaabbbb*&#@".data(using: .utf8)!,
        ]
        let offsets: [Int] = [0, 3]
        let beet = FixedSizeBeet(value: .scalar(FixedSizeBuffer(bytes: 3 * 4)))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
}
