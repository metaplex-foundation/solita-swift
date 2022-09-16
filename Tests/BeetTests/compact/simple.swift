import Foundation
import XCTest
@testable import Beet

enum ValueType {
    case string(String)
    case number(Int)
    case arrayString([String])
    case arrayInt([Int])
    case dict([String: Any])
    case none
}
struct Fixture {
    let value: ValueType
    let data: [UInt8]
}

extension Fixture: Decodable {
    enum CodingKeys: String, CodingKey { // declaring our keys
       case value = "value"
       case data = "data"
     }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var value: ValueType = .none
        do {
            let valueString: String = try container.decode(String.self, forKey: .value)
            value = .string(valueString)
        } catch {}
        do {
            let valueInt: Int = try container.decode(Int.self, forKey: .value)
            value = .number(valueInt)
        } catch {}
        do {
            let valueArrayString: [String] = try container.decode([String].self, forKey: .value)
            value = .arrayString(valueArrayString)
        } catch {}
        do {
            let valueArrayInt: [Int] = try container.decode([Int].self, forKey: .value)
            value = .arrayInt(valueArrayInt)
        } catch {}
        do {
            let valueDict: [String: Any] = try container.decode([String: Any].self, forKey: .value)
            value = .dict(valueDict)
        } catch {}
        let data: [UInt8] = try container.decode([UInt8].self, forKey: .data)
        self.init(value: value, data: data)
    }
}

typealias Fixtures = [String: [Fixture]]

fileprivate func getDencoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    return decoder
}

final class simpleTests: XCTestCase {
    func testCompatSimpleStrings() {
        let beet = Utf8String()
        let fixtures = stubbedResponse("simple")
        for fixture in fixtures["strings"]! {
            switch fixture.value {
            case .string(let string):
                checkFixedSerialization(fixedBeet: beet.toFixedFromValue(val: string), value: string, data: Data(fixture.data), description: "")
                checkFixedSerialization(fixedBeet: beet.toFixedFromData(buf: Data(fixture.data), offset: 0), value: string, data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
            
        }
    }
    
    func testCompatSimpleU8s() {
        let beet = u8()
        let fixtures = stubbedResponse("simple")
        for fixture in fixtures["u8s"]! {
            switch fixture.value {
            case .number(let number):
                checkFixedSerialization(fixedBeet: .init(value: .scalar(beet)), value: UInt8(number), data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
        }
    }
    
    func testCompatSimpleU128s() {
        let beet = u128()
        let fixtures = stubbedResponse("simple")
        for fixture in fixtures["u128s"]! {
            switch fixture.value {
            case .string(let string):
                checkFixedSerialization(fixedBeet: .init(value: .scalar(beet)), value: UInt128(string), data: Data(fixture.data), description: "")
            case .number(let number):
                checkFixedSerialization(fixedBeet: .init(value: .scalar(beet)), value: UInt128(number), data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
            
        }
    }
}

func stubbedResponse(_ filename: String) -> Fixtures {
    @objc class FeelitTests: NSObject { }
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent().deletingLastPathComponent()
    let resourceURL = thisDirectory.appendingPathComponent("Resources/fixtures/\(filename).json")
    let json = try! Data(contentsOf: resourceURL)
    return try! getDencoder().decode(Fixtures.self, from: json)
}
