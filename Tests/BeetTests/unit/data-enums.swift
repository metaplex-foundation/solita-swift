import Foundation
import XCTest
@testable import Beet

func checkCase<E: Equatable>(
    maybeFixable: Beet,
    expected: E
){
    var largerBuf: Data
    let offset = 100
    // Exact buffer
    switch maybeFixable {
    case .fixedBeet(let fixedSizeBeet):
        let beet = fixedSizeBeet
        largerBuf = Data(count: offset + Int(beet.byteSize))
        beet.write(buf: &largerBuf, offset: offset, value: expected)
        let actual: E = beet.read(buf: largerBuf, offset: offset)
        XCTAssertEqual(actual, expected)
    case .fixableBeat(let fixableBeet):
        let beet = fixableBeet.toFixedFromValue(val: expected)
        largerBuf = Data(count: offset + Int(beet.byteSize))
        beet.write(buf: &largerBuf, offset: offset, value: expected)
        let actual: E = beet.read(buf: largerBuf, offset: offset)
        XCTAssertEqual(actual, expected)
    }
    
    // Larger buffer
    switch maybeFixable {
    case .fixedBeet(let fixedSizeBeet):
        let beet = fixedSizeBeet
        largerBuf = Data(count: offset + Int(beet.byteSize) + offset)
        beet.write(buf: &largerBuf, offset: offset, value: expected)
        let actual: E = beet.read(buf: largerBuf, offset: offset)
        XCTAssertEqual(actual, expected)
    case .fixableBeat(let fixableBeet):
        let beet = fixableBeet.toFixedFromValue(val: expected)
        largerBuf = Data(count: offset + Int(beet.byteSize) + offset)
        beet.write(buf: &largerBuf, offset: offset, value: expected)
        let actual: E = beet.read(buf: largerBuf, offset: offset)
        XCTAssertEqual(actual, expected)
    }
    
}

enum Ty: Equatable {
    case fixable(s: String)
    case fixed (UInt8)
    case none
}
extension Ty: ConstructableWithDiscriminator {
    init?(discriminator: UInt8, params: [String: Any]) {
        switch discriminator{
        case 0: self = .fixable(s: params["s"] as! String)
        case 1: self = .fixed(params.first!.value as! UInt8)
        case 2: self = .none
        default: return nil
        }
    }
    
    static func paramsOrderedKeys(discriminator: UInt8) -> [ParamkeyTypes] {
        switch discriminator{
        case 0: return [.key("s")]
        case 1: return [.noKey]
        case 2: return []
        default: return []
        }
    }
}

enum Ty2: Equatable {
    case fixedOne(n1: UInt8)
    case fixedTwo(n2: UInt8, array: [UInt8])
}
extension Ty2: ConstructableWithDiscriminator {
    init?(discriminator: UInt8, params: [String: Any]) {
        switch discriminator{
        case 0: self = Ty2.fixedOne(n1: params["n1"] as! UInt8)
        case 1: self = Ty2.fixedTwo(n2: params["n2"] as! UInt8, array: params["array"] as! [UInt8])
        default: return nil
        }
    }
    
    static func paramsOrderedKeys(discriminator: UInt8) -> [ParamkeyTypes] {
        switch discriminator {
        case 0: return [.key("n1")]
        case 1: return [.key("n2"), .key("array")]
        default: return []
        }
    }
}

enum Ty3: Equatable {
    case fixableOne(n1: String)
    case fixableTwo(n2: String, array: [UInt8])
}
extension Ty3: ConstructableWithDiscriminator {
    init?(discriminator: UInt8, params: [String: Any]) {
        switch discriminator{
        case 0: self = Ty3.fixableOne(n1: params["n1"] as! String)
        case 1: self = Ty3.fixableTwo(n2: params["n2"] as! String, array: params["array"] as! [UInt8])
        default: return nil
        }
    }
    
    static func paramsOrderedKeys(discriminator: UInt8) -> [ParamkeyTypes] {
        switch discriminator {
        case 0: return [.key("n1")]
        case 1: return [.key("n2"), .key("array")]
        default: return []
        }
    }
}

enum Ty4: Equatable {
    case data(UInt8)
}
extension Ty4: ConstructableWithDiscriminator {
    init?(discriminator: UInt8, params: [String: Any]) {
        switch discriminator{
        case 0: self = Ty4.data(params.first!.value as! UInt8)
        default: return nil
        }
    }
    
    static func paramsOrderedKeys(discriminator: UInt8) -> [ParamkeyTypes] {
        switch discriminator {
        case 0: return [.noKey]
        default: return []
        }
    }
}

enum Ty5: Equatable {
    case data(String)
}
extension Ty5: ConstructableWithDiscriminator {
    init?(discriminator: UInt8, params: [String: Any]) {
        switch discriminator{
        case 0: self = Ty5.data(params.first!.value as! String)
        default: return nil
        }
    }
    
    static func paramsOrderedKeys(discriminator: UInt8) -> [ParamkeyTypes] {
        switch discriminator {
        case 0: return [.noKey]
        default: return []
        }
    }
}

final class dataEnumTests: XCTestCase {
    func testDataEnumsFixableFixedDataStructs() {
        let beet = DataEnum<Ty>(variants: [
            ("fixable",.fixableBeat(Utf8String())),
            ("fixed", .fixedBeet(.init(value: .scalar(u8())))),
            ("none", .fixedBeet(.init(value: .scalar(coptionNone(description: "nothing")))))
        ])
        checkCase(maybeFixable: Beet.fixableBeat(beet), expected: Ty.fixable(s: "hello"))
        checkCase(maybeFixable: Beet.fixableBeat(beet), expected: Ty.fixed(1))
        checkCase(maybeFixable: Beet.fixableBeat(beet), expected: Ty.none)

    }
    
    func testDataEnumsFixedOnlyDataStructs() {
        let beet = DataEnum<Ty2>(variants: [
            ("fixedOne", .fixedBeet(.init(value: .scalar(u8())))),
            ("fixedTwo", .fixedBeet(.init(value: .scalar(BeetArgsStruct(fields: [
                ("n2", FixedSizeBeet(value: .scalar(u8()))),
                ("array", FixedSizeBeet(value: .collection(UniformFixedSizeArray<UInt8>(element: FixedSizeBeet(value: .scalar(u8())), len: 2))))
                 ]
            )))))
        ])
        checkCase(maybeFixable: Beet.fixableBeat(beet), expected: Ty2.fixedOne(n1: UInt8(1)))
        checkCase(maybeFixable: Beet.fixableBeat(beet), expected: Ty2.fixedTwo(n2: UInt8(11), array: [3, 4]))

    }
    
    func testDataEnumsFixableOnlyDataStructs() {
        let beet = DataEnum<Ty3>(variants: [
            ("fixableOne", .fixableBeat(FixableBeetArgsStruct<Ty3>(fields: [("n1", .fixableBeat(Utf8String()))]))),
            ("fixableTwo", .fixableBeat(FixableBeetArgsStruct<Ty3>(fields: [
                ("n2", .fixableBeat(Utf8String())),
                ("array", .fixableBeat(array(element: .fixedBeet(.init(value: .scalar(u8()))))))
            ])))
        ])
        checkCase(maybeFixable: Beet.fixableBeat(beet), expected: Ty3.fixableTwo(n2: "11", array: [3, 4, 5]))
        checkCase(maybeFixable: Beet.fixableBeat(beet), expected: Ty3.fixableOne(n1: "1"))
    }
    
    func testDataEnumsDirectFixedData() {
        let beet = DataEnum<Ty4>(variants: [
            ("data", .fixedBeet(.init(value: .scalar(u8()))))
        ])
        checkCase(maybeFixable: Beet.fixableBeat(beet), expected: Ty4.data(42))
    }
    
    func testDataEnumsDirectFixableData() {
        let beet = DataEnum<Ty5>(variants: [
            ("data", .fixableBeat(Utf8String()))
        ])
        checkCase(maybeFixable: Beet.fixableBeat(beet), expected: Ty5.data("AAA"))
    }
}
