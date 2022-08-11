import Foundation
import XCTest
@testable import Beet
import Solana

func verify<X : Equatable, B>(
    beet: FixableBeetStruct<X>,
    args: Args,
    expected: BeetStruct<B>
) {
    
    let fixedFromArgs = beet.toFixedFromValue(val: args)
    var data: Data
    switch fixedFromArgs.value {
    case .scalar(let type):
        data = Data(count: Int(type.byteSize))
        type.write(buf: &data, offset: 0, value: beet.construct(args))
    case .collection(let type):
        data = Data(count: Int(type.byteSize))
        type.write(buf: &data, offset: 0, value: beet.construct(args))
    }
    
    let fixedFromData: FixedSizeBeet = beet.toFixedFromData(buf: data, offset: 0)
    
    switch fixedFromData.value {
    case .scalar(let type):
        let deserializedArgs: X  = type.read(buf: data, offset: 0)
        XCTAssertEqual(deserializedArgs, beet.construct(args))
    case .collection(let type):
        let deserializedArgs: X = type.read(buf: data, offset: 0)
        XCTAssertEqual(deserializedArgs, beet.construct(args))
    }
    
    
}

final class structsFixableTests: XCTestCase {
    func testStructsFixableStructWithTopLevelVec() {
        struct X: Equatable {
            let ids: [UInt32]
            let count: UInt32
        }
        let xStruct = FixableBeetStruct<X>(
            fields: [
                ("ids", Beet.fixableBeat(array(element: .fixedBeet(.init(value: .scalar(u32())))))),
                ("count", Beet.fixedBeet(.init(value: .scalar(u32())))),
            ], construct: {
                X(ids: $0["ids"] as! [UInt32],
                  count: $0["count"] as! UInt32)
            },
            description: "VecStruct"
        )
        _ = xStruct.toFixedFromValue(val: ["ids": [], "count" : 1])
        
        let expected = BeetStruct<X>(fields: [
            ( "ids", FixedSizeBeet(value: .collection(UniformFixedSizeArray<UInt32>(element: .init(value: .scalar(u32())), len: 4, lenPrefix: true)))),
            ("count", FixedSizeBeet(value: .scalar(u32()))),
        ], construct: {
            X(ids: $0["ids"] as! [UInt32],
              count: $0["count"] as! UInt32)
        }, description: "VecStruct")
        
        verify(beet: xStruct, args: ["ids": [UInt32(1), UInt32(2), UInt32(3), UInt32(4)], "count" : UInt32(1)], expected: expected)
        
    }
    
    
    func testStructFixableStructWithTopLevelString() {
        struct Y: Equatable {
            let name: String
            let age: UInt32
        }
        let yStruct = FixableBeetStruct<Y>(
            fields: [
                ("name", Beet.fixableBeat(Utf8String())),
                ("age", Beet.fixedBeet(.init(value: .scalar(u32())))),
            ], construct: {
                Y(name: $0["name"] as! String,
                  age: $0["age"] as! UInt32)
            },
            description: "CustomerStruct"
        )
        _ = yStruct.toFixedFromValue(val: ["name": "XXXX", "age" : 1])
        
        let expected = BeetStruct<Y>(fields: [
            ( "name", FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: UInt(11))))),
            ("age", FixedSizeBeet(value: .scalar(u32()))),
        ], construct: {
            Y(name: $0["name"] as! String,
              age: $0["age"] as! UInt32)
        }, description: "CustomerStruct")
        
        verify(beet: yStruct, args: ["name": "Hello World", "age" : UInt32(18)], expected: expected)
    }
    
    func testStructFixableStructWithNestedVecAndString() {
        struct Z: Equatable {
            let maybeIds: [UInt32]?
            let contributors: [String]
        }
        let zStruct = FixableBeetStruct<Z>(
            fields: [
                ("maybeIds", Beet.fixableBeat(coption(inner: .fixableBeat(array(element: .fixedBeet(.init(value: .scalar(u32())))))))),
                ("contributors", Beet.fixableBeat(array(element: .fixableBeat(Utf8String()))))
            ], construct: {
                Z(
                    maybeIds: $0["maybeIds"] as! [UInt32]?,
                    contributors: $0["contributors"] as! [String])
            },
            description: "ContributorsStruct"
        )
        _ = zStruct.toFixedFromValue(val: ["maybeIds": [UInt32(1), UInt32(2), UInt32(3)], "contributors" : ["bob", "alice"]])
        
        let expected = BeetArgsStruct(fields: [
            ("maybeIds", .init(value: .collection(UniformFixedSizeArray<UInt32>(element: .init(value: .scalar(u32())), len: 3)))),
            ("contributors", .init(value: .collection(FixedSizeArray<String>(elements: [
                .init(value: .collection(FixedSizeUtf8String(stringByteLength: 3))),
                .init(value: .collection(FixedSizeUtf8String(stringByteLength: 5)))
            ], elementsByteSize: 2))))
        ], description: "ContributorsStruct")
        
        verify(beet: zStruct, args:  ["maybeIds": [UInt32(1), UInt32(2), UInt32(3)], "contributors" : ["bob", "alice"]], expected: expected)
    }
    
    func testFixableStructWithTopLevelStringNestedInsideOtherStruct() {
        struct InnerArgs: Equatable {
            let name: String
            let age: UInt8
        }
    
        let innerStruct = FixableBeetStruct<InnerArgs>(
            fields: [
                ("name", Beet.fixableBeat(Utf8String())),
                ("age", Beet.fixedBeet(FixedSizeBeet(value: .scalar(u8()))))
            ], construct: {
                InnerArgs(
                    name: $0["name"] as! String,
                    age: $0["age"] as! UInt8)
            },
            description: "InnerStruct"
        )
                
        let expected = BeetStruct<InnerArgs>(fields: [
            ( "name", FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: UInt(3))))),
            ("age", FixedSizeBeet(value: .scalar(u8()))),
        ], construct: {
            InnerArgs(
                name: $0["name"] as! String,
                age: $0["age"] as! UInt8)
        }, description: "InnerStruct")
        
        verify(beet: innerStruct, args: ["name": "bob", "age": UInt8(18)], expected: expected)
        
    }
}
