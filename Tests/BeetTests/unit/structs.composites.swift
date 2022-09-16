import Foundation
import XCTest
@testable import Beet

let result1 = { Results(win: 20, totalWin: 1200, losses: -455) }
let result2 = { Results(win: 30, totalWin: 100, losses: -3) }
let result3 = { Results(win: 3, totalWin: 999, losses: 0) }

enum ResultKind : CaseIterable {
    case Good
    case Bad
}

extension ResultKind: RawRepresentable{
    typealias RawValue = UInt8
    init?(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .Good
        case 1: self = .Bad
        default : return nil
        }
    }
    
    var rawValue: UInt8 {
        switch self {
        case .Good:
            return 0
        case .Bad:
            return 1
        }
    }
}

final class structsCompositesTests: XCTestCase {
    func testStructRoundtripCOptionStruct() {
        let fixableBeet: FixableBeet = coption(inner: .fixedBeet(FixedSizeBeet(value: .scalar(Results.struct))))
        let offsets = [0, 8]
        let arg = result1()
        let beet = fixableBeet.toFixedFromValue(val: arg)
        for offset in offsets {
            switch beet.value {
            case .scalar(let type):
                var buf = Data(count: offset + Int(type.byteSize) + offset)
                type.write(buf: &buf, offset: offset, value: arg)
                let deserialized: Results = type.read(buf: buf, offset: offset)
                XCTAssertEqual(deserialized, arg)
            case .collection(let type):
                var buf = Data(count: offset + Int(type.byteSize) + offset)
                type.write(buf: &buf, offset: offset, value: arg)
                let deserialized: Results = type.read(buf: buf, offset: offset)
                XCTAssertEqual(deserialized, arg)
            }
            
        }
    }
    
    func testStructRoundtripArrayStruct() {
        let beet = UniformFixedSizeArray<Results>(element: FixedSizeBeet(value: .scalar(Results.struct)), len: 3)
        let offsets = [0, 8]
        
        for offset in offsets {
            var buf = Data(count: offset + Int(beet.byteSize) + offset)
            beet.write(buf: &buf, offset: offset, value: [result1(), result2(), result3()])
            let deserialized: [Results] = beet.read(buf: buf, offset: offset)
            XCTAssertEqual(deserialized, [result1(), result2(), result3()])
        }
    }
    
    func testStructRoundtripEnumStruct() {
        let goodResult = UniformDataEnumData(kind: ResultKind.Good, data: result3() )
        let badResult = UniformDataEnumData(kind: ResultKind.Bad, data: result2() )
        
        let beet = FixedSizeBeet(value: .scalar(UniformDataEnum<ResultKind, Results>(inner: FixedSizeBeet(value: .scalar(Results.struct)))))
        
        let offsets = [0, 8]

        for offset in offsets {
            switch beet.value {
            case .scalar(let type):
                var buf = Data(count: offset + Int(type.byteSize) + offset)
                type.write(buf: &buf, offset: offset, value: goodResult)
                let deserialized: UniformDataEnumData<ResultKind, Results>  = type.read(buf: buf, offset: offset)
                XCTAssertEqual(deserialized, goodResult)
            case .collection:
                XCTFail()
            }
        }
        
        for offset in offsets {
            switch beet.value {
            case .scalar(let type):
                var buf = Data(count: offset + Int(type.byteSize) + offset)
                type.write(buf: &buf, offset: offset, value: badResult)
                let deserialized: UniformDataEnumData<ResultKind, Results> = type.read(buf: buf, offset: offset)
                XCTAssertEqual(deserialized, badResult)
            case .collection:
                XCTFail()
            }
        }
    }
}

