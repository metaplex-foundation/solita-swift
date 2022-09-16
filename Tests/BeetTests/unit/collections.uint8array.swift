import Foundation
import XCTest
@testable import Beet

final class collectionUint8ArrayTests: XCTestCase {
    func testCollectionsFixedSizeUint8Array() {
        let cases: [Data] = [Data([1, 2, 0xff]),Data([0, 10, 99])]
        let offsets: [Int] = [0, 3]
        let beet = FixedSizeBeet(value: .scalar(FixedSizeUint8Array(len: 3)))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testCollectionsFixableSizeUint8Array() {
        let cases: [Data] = [Data([1, 2, 3]),Data([0, 10, 99, 100, 101])]
        let offsets: [Int] = [0, 3]
        let beet = Uint8Array()
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
        switch beet.toFixedFromData(buf: Data([3, 0, 0, 0, 1, 2, 3]), offset: 0).value {
        case .scalar(let type):
            XCTAssertEqual(type.byteSize, 4 + 3)
        case .collection:
            XCTFail()
        }
        
        switch beet.toFixedFromData(buf: Data([0, 5, 0, 0, 0, 1, 2, 3, 4, 5]), offset: 1).value {
        case .scalar(let type):
            XCTAssertEqual(type.byteSize, 4 + 5)
        case .collection:
            XCTFail()
        }
    }
}
