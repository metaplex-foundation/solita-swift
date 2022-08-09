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
    
    func testCollectionsFixedSizeArrayOfu8NotIncludeSize() {
        let cases: [[UInt8]] = [
            [1, 2, 0xff],
            [0, 1, 2],
          ]
        let offsets: [Int] = [0, 4]
        let beet = FixedSizeBeet(value: .collection(UniformFixedSizeArray<UInt8>(element: FixedSizeBeet(value: .scalar(u8())), len: 3)))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testCollectionsFixedSizeArrayOfStringIncludeSize() {
        let cases: [[String]] = [
            ["abc ", "*def", "😁"],
            ["aaaa", "bbbb", "*&#@"],
          ]
        let offsets: [Int] = [0, 3]
        let beet = FixedSizeBeet(value: .collection(UniformFixedSizeArray<String>(element: FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: 4))), len: 3, lenPrefix: true)))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testCollectionsFixedSizeArrayOfStringNotIncludeSize() {
        let cases: [[String]] = [
            ["abc ", "*def", "😁"],
            ["aaaa", "bbbb", "*&#@"],
          ]
        let offsets: [Int] = [0, 3]
        let beet = FixedSizeBeet(value: .collection(UniformFixedSizeArray<String>(element: FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: 4))), len: 3)))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
}
