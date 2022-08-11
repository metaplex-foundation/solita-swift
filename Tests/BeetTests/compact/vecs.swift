import Foundation
import XCTest
@testable import Beet
import Solana

final class vecsTests: XCTestCase {
    func testCompatVecsU8s() {
        let fixtures = stubbedResponse("vecs")
        for fixture in fixtures["u8s"]!.dropLast() {
            let beet = array(element: .fixedBeet(.init(value: .scalar(u8()))))
            switch fixture.value {
            case .arrayInt(let numbers):
                let u8numbers = numbers.map { UInt8($0) }
                checkFixedSerialization(fixedBeet: beet.toFixedFromValue(val: u8numbers), value: u8numbers, data: Data(fixture.data), description: "")
                checkFixedSerialization(fixedBeet: beet.toFixedFromData(buf: Data(fixture.data), offset: 0), value: u8numbers, data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
        }
        
        for fixture in fixtures["u8s"]!.dropLast() {
            let beet = Uint8Array()
            switch fixture.value {
            case .arrayInt(let numbers):
                let u8numbers = numbers.map { UInt8($0) }
                let uint8Value = Data(u8numbers)
                checkFixedSerialization(fixedBeet: beet.toFixedFromValue(val: uint8Value), value: uint8Value, data: Data(fixture.data), description: "")
                checkFixedSerialization(fixedBeet: beet.toFixedFromData(buf: Data(fixture.data), offset: 0), value: uint8Value, data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
        }
    }
    
    func testCompatVecsStrings() {
        let beet = array(element: .fixableBeat(Utf8String()))
        let fixtures = stubbedResponse("vecs")
        for fixture in fixtures["strings"]! {
            switch fixture.value {
            case .arrayInt(let numbers):
                let u8numbers = numbers.map { UInt8($0) }
                let strings = Data(u8numbers).bytes
                checkFixedSerialization(fixedBeet: beet.toFixedFromValue(val: strings), value: strings, data: Data(fixture.data), description: "")
                checkFixedSerialization(fixedBeet: beet.toFixedFromData(buf: Data(fixture.data), offset: 0), value: strings, data: Data(fixture.data), description: "")
            case .arrayString(let strings):
                checkFixedSerialization(fixedBeet: beet.toFixedFromValue(val: strings), value: strings, data: Data(fixture.data), description: "")
                checkFixedSerialization(fixedBeet: beet.toFixedFromData(buf: Data(fixture.data), offset: 0), value: strings, data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
        }
    }
}
