import Foundation
import XCTest
@testable import Beet

final class CompositesCoptionTests: XCTestCase {
    func testCompositesCOptionU8() {
        let cases: [COption<UInt8>] = [1, 2, nil, 0xff]
        let offsets: [Int] = [0, 4]
        let beet = coption(inner: .fixedBeet(FixedSizeBeet(value: .scalar(u8()))))
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
    }
    
    func testCompositesCOptionU32() {
        let cases: [COption<UInt32>] = [1, nil, 0xff, 0xffff, 0xffffffff]
        let offsets: [Int] = [0, 4]
        let beet = coption(inner: .fixedBeet(FixedSizeBeet(value: .scalar(u32()))))
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
    }
    
    func testCompositesCOptionString() {
        let cases: [COption<String>] = ["abc", "abcxyz", nil]
        let offsets: [Int] = [0, 2]
        let beet = coption(inner: .fixableBeat(Utf8String()))
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
    }
}
