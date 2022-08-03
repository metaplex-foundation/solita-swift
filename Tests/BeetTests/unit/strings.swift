import Foundation
import XCTest
@testable import Beet
import Solana

func checkCases<U: Equatable>(
    offsets: [Int],
    cases: [U],
    fixableBeet: FixableBeet
) {
    for offset in offsets {
        for x in cases {
            print("Input: \(x)")
            print("Offset: \(offset)")
            
            let beet = fixableBeet.toFixedFromValue(val: x)
            
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

final class stringTests: XCTestCase {
    func testCollectionsFixedSizeUtf8StringsSize1() {
        let cases = ["a", "b", "z"]
        let offsets: [Int] = [0, 4]
        let beet = FixedSizeBeet(value: .scalar(FixedSizeUtf8String(stringByteLength: 1)))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testCollectionsFixedSizeUtf8StringsSize3() {
        let cases = ["abc", "xYz"]
        let offsets: [Int] = [0, 4]
        let beet = FixedSizeBeet(value: .scalar(FixedSizeUtf8String(stringByteLength: 3)))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testCollectionsFixedSizeUtf8StringsSize4() {
        let cases = ["abcd", "😁"]
        let offsets: [Int] = [0, 4]
        let beet = FixedSizeBeet(value: .scalar(FixedSizeUtf8String(stringByteLength: 4)))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testCollectionsUtf8Strings() {
        let cases = ["abcdefg", "😁", "😁😁😁", ""]
        let offsets: [Int] = [0, 4]
        let beet = Utf8String()
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
    }
}


