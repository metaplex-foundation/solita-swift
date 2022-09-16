import Foundation
import XCTest
@testable import Beet

enum Directions: CaseIterable {
    case Up
    case Right
    case Down
    case Left
    
    static func stringToEnum(string: String) -> Directions{
        switch string {
            case "Up" : return .Up
            case "Right" : return .Right
            case "Down" : return .Down
            case "Left" : return .Left
            default:
                fatalError()
        }
    }
}

extension Directions : RawRepresentable {
    typealias RawValue = UInt8
    init?(rawValue: UInt8){
        switch rawValue {
        case 0 : self = .Up
        case 1 : self = .Right
        case 2 : self = .Down
        case 3 : self = .Left
        default : return nil
        }
    }
    
    var rawValue: UInt8 {
        switch self {
        case .Up : return 0
        case .Right :  return 1
        case .Down : return 2
        case .Left : return 3
        }
    }
}

enum Milligrams: CaseIterable {
    case Grams
    case Kilograms
    
    static func stringToEnum(string: String) -> Milligrams{
        switch string {
            case "Grams" : return .Grams
            case "Kilograms" : return .Kilograms
            default:
                fatalError()
        }
    }
}

extension Milligrams : RawRepresentable {
    typealias RawValue = UInt8
    init?(rawValue: UInt8){
        switch rawValue {
        case 0 : self = .Grams
        case 1 : self = .Kilograms
        default : return nil
        }
    }
    
    var rawValue: UInt8 {
        switch self {
        case .Grams : return 0
        case .Kilograms :  return 1
        }
    }
}


final class enumsTests: XCTestCase {
    func testCompatEnumsDirections() {
        let beet = FixedSizeBeet(value: .scalar(FixedScalarEnum<Directions>()))
        let fixtures = stubbedResponse("enums")
        for fixture in fixtures["directions"]! {
            switch fixture.value {
            case .string(let string):
                checkFixedSerialization(fixedBeet: beet, value: Directions.stringToEnum(string: string), data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
            
        }
    }
    
    func testCompatEnumsMilligrams() {
        let beet = FixedSizeBeet(value: .scalar(FixedScalarEnum<Milligrams>()))
        let fixtures = stubbedResponse("enums")
        for fixture in fixtures["milligrams"]! {
            switch fixture.value {
            case .string(let string):
                checkFixedSerialization(fixedBeet: beet, value: Milligrams.stringToEnum(string: string), data: Data(fixture.data), description: "")
            default:
                XCTFail()
            }
            
        }
    }
    
    func testCompatDirectionsUsingInt() {
        let beet = FixedSizeBeet(value: .scalar(FixedScalarEnum<Directions>()))
        var buf = Data(count: Int(beet.byteSize))
        beet.write(buf: &buf, offset: 0, value: Directions.Down)
        checkFixedSerialization(fixedBeet: beet, value: Directions.Down, data: Data([0x02]), description: "")
        checkFixedSerialization(fixedBeet: beet, value: Directions.Down, data: Data([0x02]), description: "")
    }
}
