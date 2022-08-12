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
    
    static func convertToKindData(value: [String: Any]) -> Simples{
        let dict = value.first!.value as! [String: Any]
        switch value.first!.key {
        case "First": return .First(first_field: UInt32(dict["first_field"] as! Int))
        case "Second": return .Second(second_field: UInt32(dict["second_field"] as! Int ))
        default: fatalError()
        }
      
    }
}


enum Collections: ConstructableWithDiscriminator & Equatable{
    case V1(symbol: String, verified_creators: [UInt8], whitelist_root: [UInt8])
    case V2(collection_mint: UInt8)
    
    init?(discriminator: UInt8, params: [String : Any]) {
        switch discriminator{
        case 0: self = Collections.V1(
            symbol: params["symbol"] as! String,
            verified_creators: params["verified_creators"] as! [UInt8],
            whitelist_root: params["whitelist_root"] as! [UInt8]
        )
        case 1: self = Collections.V2(collection_mint: params["collection_mint"] as! UInt8)
        default: return nil
        }
    }
    
    static func paramsOrderedKeys(discriminator: UInt8) -> [ParamkeyTypes] {
        switch discriminator{
        case 0: return [.key("symbol"), .key("verified_creators"), .key("whitelist_root")]
        case 1: return [.key("collection_mint")]
        default: return []
        }
    }
    
    static func convertToKindData(value: [String: Any]) -> Collections{
        let dict = value.first!.value as! [String: Any]
        switch value.first!.key {
        case "V1": return .V1(
            symbol: dict["symbol"] as! String,
            verified_creators: (dict["verified_creators"] as! [Int]).map{ UInt8($0) },
            whitelist_root: (dict["whitelist_root"] as! [Int]).map{ UInt8($0) }
        )
        case "V2": return .V2(collection_mint: UInt8(dict["collection_mint"] as! Int))
        default: fatalError()
        }
      
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
                let val = Simples.convertToKindData(value: dictionary)
                print(dictionary)
                checkFixableFromDataSerialization(fixabledBeet: beet, value: val, data: Data(fixture.data), description: "")
                checkFixableFromValueSerialization(fixabledBeet: beet, value: val, data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
        }
    }
    
    func testCompatDataEnumsCollectionInfo() {
        let beet = DataEnum<Collections>(variants: [
            ("V1",
             .fixableBeat(FixableBeetArgsStruct<Any>(fields: [
                ("symbol", .fixableBeat(Utf8String())),
                ("verified_creators", .fixableBeat(array(element: .fixedBeet(.init(value: .scalar(u8())))))),
                ("whitelist_root", .fixedBeet(.init(value: .collection(UniformFixedSizeArray<UInt8>(element: .init(value: .scalar(u8())), len: 32)))))
             ]))),
            ("V2", .fixableBeat(FixableBeetArgsStruct<Any>(fields: [
                ("collection_mint", .fixedBeet(.init(value: .scalar(u8()))))
            ])))
        ])
        
        let fixtures = stubbedResponse("data_enums")
        for fixture in fixtures["collections"]! {
            switch fixture.value {
            case .dict(let dictionary):
                let val = Collections.convertToKindData(value: dictionary)
                print(val)
                checkFixableFromDataSerialization(fixabledBeet: beet, value: val, data: Data(fixture.data), description: "")
                checkFixableFromValueSerialization(fixabledBeet: beet, value: val, data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
        }
    }
}
