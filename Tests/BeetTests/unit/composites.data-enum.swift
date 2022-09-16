import Foundation
import XCTest
@testable import Beet

final class CompositesDataEnumsTests: XCTestCase {
    func testCompositesDataEnumColorString() {
        let cases: [UniformDataEnumData<Color, String>] = [
            UniformDataEnumData(kind: Color.red, data: "red++" ),
            UniformDataEnumData(kind: Color.green, data: "green" ),
            UniformDataEnumData(kind: Color.blue, data: "blue+" ),
          ]
        let offsets: [Int] = [0, 4]
        let beet = FixedSizeBeet(value: .scalar(UniformDataEnum<Color, String>(inner: FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: 5))))))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testCompositesDataEnumSeatsU8() {
        let cases: [UniformDataEnumData<Seat, UInt8>] = [
            UniformDataEnumData(kind: Seat.HU, data: 2 ),
            UniformDataEnumData(kind: Seat.Short, data: 6 ),
            UniformDataEnumData(kind: Seat.Full, data: 9 ),
          ]
        let offsets: [Int] = [0, 4]
        let beet = FixedSizeBeet(value: .scalar(UniformDataEnum<Seat, UInt8>(inner: FixedSizeBeet(value: .scalar(u8())))))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testCompositesDataEnumSeatsU8Array() {
        let cases: [UniformDataEnumData<Seat, [UInt8]>] = [
            UniformDataEnumData(kind: Seat.HU, data: [1, 2, 0, 0, 0, 0, 0, 0, 0] ),
            UniformDataEnumData(kind: Seat.Short, data: [1, 2, 3, 4, 5, 6, 0, 0, 0] ),
            UniformDataEnumData(kind: Seat.Full, data: [1, 2, 3, 4, 5, 6, 7, 8, 9] ),
          ]
        let offsets: [Int] = [0, 4]
        
        let beet = FixedSizeBeet(value: .scalar(UniformDataEnum<Seat, [UInt8]>(inner: FixedSizeBeet(value: .collection(UniformFixedSizeArray<UInt8>(element: FixedSizeBeet(value: .scalar(u8())), len: 9))))))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
}
