import Foundation
import XCTest
@testable import Beet

final class collectionArrayTests: XCTestCase {
    func testCollectionsNonUniformSizeArrayOfStrings() {
        let cases: [[String]] = [
            ["abc ", "*def", "😁"],
            ["aaaa", "bbbb", "*&#@"],
        ]
        let offsets: [Int] = [0, 3]
        let beet = array(element: .fixableBeat(Utf8String()))
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
    }
    func testCollectionsNonUniformSizeArrayOfOptionU8() {
        let cases: [[COption<UInt8>]] = [
            [],
            [1, 2, 3]
        ]
        let offsets: [Int] = [0, 3]
        let beet = array(element: .fixableBeat(coption(inner: .fixedBeet(FixedSizeBeet(value: .scalar(u8()))))))
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
    }
    
    func testCollectionsNonUniformSizeArrayOfOptionU8WithNil() {
        let cases: [[COption<UInt8>]] = [
            [nil, nil, nil],
            [1, nil, 255],
        ]
        let offsets: [Int] = [0, 3]
        let beet = array(element: .fixableBeat(coption(inner: .fixedBeet(FixedSizeBeet(value: .scalar(u8()))))))
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
    }
    
    func testCollectionsNonUniformSizeArrayOfOptionString() {
        let cases: [[COption<String>]] = [
            [],
            [nil, nil],
            ["a", "abcdef", "😁"],
            ["aa", nil, "bbb", nil, "*&#@!!"],
        ]
        let offsets: [Int] = [0, 3]
        let beet = array(element: .fixableBeat(coption(inner: .fixableBeat(Utf8String()))))
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
    }
    
    func testCollectionsNonUniformSizeArrayOfOptionArrayString() {
        let cases = [
            [],
            [nil, nil],
            [["a "], ["abcdef", "😁"]],
            [["aa", "bbb"], nil, ["*&#@!!", "abcdef", "😁", "aa", "bb", "ccccc"]],
        ]
        let offsets: [Int] = [0, 3]
        let beet = array(element: .fixableBeat(coption(inner: .fixableBeat(array(element: .fixableBeat(coption(inner: .fixableBeat(Utf8String()))))))))
        checkCases(offsets: offsets, cases: cases, fixableBeet: beet)
    }
}
