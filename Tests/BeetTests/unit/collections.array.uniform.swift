import Foundation
import XCTest
@testable import Beet
import Solana

final class collectionArrayUniformTests: XCTestCase {
    func testCollectionsFixedSizeArrayOfu8IncludeSize() {
        let cases: [[UInt8]] = [
            [1, 2, 0xff],
            [0, 1, 2],
          ]
        let offsets: [Int] = [0, 4]
        let beet = FixedSizeBeet(value: .collection(UniformFixedSizeArray<UInt8>(element: FixedSizeBeet(value: .scalar(u8())), len: 3, lenPrefix: true)))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
}
