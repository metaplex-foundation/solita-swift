import Foundation
import XCTest
@testable import Beet
import Solana

enum Simples: ConstructableWithDiscriminator & Equatable{
    case First(first_field: UInt32)
    case Second(second_field: UInt32)
    
    init?(discriminator: UInt8, params: [String : Any]) {
        switch discriminator{
        case 0: self = Simples.First(first_field: params["first_field"] as! UInt32)
        case 1: self = Simples.Second(second_field: params["second_field"] as! UInt32)
        default: return nil
        }
    }
    
    static func paramsOrderedKeys(discriminator: UInt8) -> [ParamkeyTypes] {
        switch discriminator{
        case 0: return [.key("first_field")]
        case 1: return [.key("second_field")]
        default: return []
        }
    }
}
func convertToKindData(value: [String: Any]) -> Simples{
    let dict = value.first!.value as! [String: Any]
    switch value.first!.key {
    case "First": return .First(first_field: UInt32(dict["first_field"] as! Int))
    case "Second": return .Second(second_field: UInt32(dict["second_field"] as! Int ))
    default: fatalError()
    }
  
}

final class dataEnumsTests: XCTestCase {
    func testCompatDataEnumsSimples() {
        let beet = DataEnum<Simples>(variants: [
            ("First", .fixedBeet(.init(value: .scalar(BeetArgsStruct(fields: [("first_field", .init(value: .scalar( u32())))]))))),
            ("Second", .fixedBeet(.init(value: .scalar(BeetArgsStruct(fields: [("second_field", .init(value: .scalar( u32())))]))))),
        ])
        
        let fixtures = stubbedResponse("data_enums")
        for fixture in fixtures["simples"]! {
            switch fixture.value {
            case .dict(let dictionary):
                let val = convertToKindData(value: dictionary)
                print(dictionary)
                checkFixableFromDataSerialization(fixabledBeet: beet, value: val, data: Data(fixture.data), description: "")
                checkFixableFromValueSerialization(fixabledBeet: beet, value: val, data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
        }
    }
}
