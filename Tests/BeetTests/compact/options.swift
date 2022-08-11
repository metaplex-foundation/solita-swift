import Foundation
import XCTest
@testable import Beet
import Solana

final class optionsTests: XCTestCase {
    func testCompatOptionsU8s() {
        let beet = coption(inner: .fixedBeet(.init(value: .scalar(u8()))))
        let fixtures = stubbedResponse("options")
        for fixture in fixtures["u8s"]! {
            switch fixture.value {
            case .number(let number):
                checkFixedSerialization(fixedBeet: beet.toFixedFromData(buf: Data(fixture.data), offset: 0), value: UInt8(number), data: Data(fixture.data), description: "")
            case .none:
                checkFixedSerialization(fixedBeet: beet.toFixedFromData(buf: Data(fixture.data), offset: 0), value: Optional<UInt8>.none, data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
        }
    }
    
    func testCompatOptionsStrings() {
        let beet = coption(inner: .fixableBeat(Utf8String()))
        let fixtures = stubbedResponse("options")
        for fixture in fixtures["strings"]! {
            switch fixture.value {
            case .string(let string):
                checkFixedSerialization(fixedBeet: beet.toFixedFromData(buf: Data(fixture.data), offset: 0), value: string, data: Data(fixture.data), description: "")
            case .none:
                checkFixedSerialization(fixedBeet: beet.toFixedFromData(buf: Data(fixture.data), offset: 0), value: Optional<String>.none, data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
        }
    }
}
