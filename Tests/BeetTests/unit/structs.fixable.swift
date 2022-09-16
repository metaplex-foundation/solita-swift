import Foundation
import XCTest
@testable import Beet

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
        
        let expected = BeetArgsStruct(fields: [
            ( "ids", FixedSizeBeet(value: .collection(UniformFixedSizeArray<UInt32>(element: .init(value: .scalar(u32())), len: 4, lenPrefix: true)))),
            ("count", FixedSizeBeet(value: .scalar(u32()))),
        ], description: "VecStruct")
        
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
        
        let expected = BeetArgsStruct(fields: [
            ( "name", FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: UInt(11))))),
            ("age", FixedSizeBeet(value: .scalar(u32()))),
        ], description: "CustomerStruct")
        
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
    
    func testFixableStructWithTopLevelString() {
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
                
        let expected = BeetArgsStruct(fields: [
            ( "name", FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: UInt(3))))),
            ("age", FixedSizeBeet(value: .scalar(u8()))),
        ], description: "InnerStruct")
        
        verify(beet: innerStruct, args: ["name": "bob", "age": UInt8(18)], expected: expected)
    }
    
    func testFixableStructWithTopLevelStringNestedInsideOtherStruct() {
        struct InnerArgs: Equatable {
            let name: String
            let age: UInt8
        }
        
        struct ArgsX: Equatable {
            let innerArgs: InnerArgs
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
    
        let argStruct = FixableBeetStruct<ArgsX>(
            fields: [
                ("innerArgs", Beet.fixableBeat(innerStruct))
            ], construct: {
                if $0["innerArgs"] is [String: Any]{
                    return ArgsX(innerArgs: InnerArgs(name: ($0["innerArgs"] as! [String: Any])["name"] as! String, age: ($0["innerArgs"] as! [String: Any])["age"] as! UInt8))
                } else {
                    return ArgsX(innerArgs: $0["innerArgs"] as! InnerArgs)
                }
            },
            description: "Args"
        )
                
        let expected = BeetArgsStruct(fields: [
            ( "innerArgs", innerStruct.toFixedFromValue(val: ["name": "bob", "age": UInt8(18)]))
        ], description: "Args")
        verify(beet: argStruct, args: ["innerArgs": ["name": "bob", "age": UInt8(18)]], expected: expected)
    }
    
    func testToFixedStructWithNestedStructAndMixedNestedFixableAndFixedBeets() {
        struct InnerArgs: Equatable {
            let housePrices: [Int16]?
            let age: UInt8
        }
        
        struct ArgsX: Equatable {
            let innerArgs: InnerArgs
            let name: String
            let symbol: String
            let count: UInt8
        }
        
        let innerStruct = FixableBeetStruct<InnerArgs>(
            fields: [
                ("housePrices", Beet.fixableBeat(coption(inner: .fixableBeat(array(element: .fixedBeet(.init(value: .scalar(u16())))))))),
                ("age", Beet.fixedBeet(FixedSizeBeet(value: .scalar(u8()))))
            ], construct: {
                InnerArgs(
                    housePrices: $0["housePrices"] as! [Int16]?,
                    age: $0["age"] as! UInt8)
            },
            description: "InnerStruct"
        )
    
        let argStruct = FixableBeetStruct<ArgsX>(
            fields: [
                ("innerArgs", Beet.fixableBeat(innerStruct)),
                ("name", Beet.fixableBeat(Utf8String())),
                ("symbol", Beet.fixableBeat(Utf8String())),
                ("count", Beet.fixedBeet(FixedSizeBeet(value: .scalar(u8()))))
            ], construct: {
                if $0["innerArgs"] is [String: Any]{
                    return ArgsX(innerArgs: InnerArgs(housePrices: ($0["innerArgs"] as! [String: Any])["housePrices"] as! [Int16]?,
                                                      age: ($0["innerArgs"] as! [String: Any])["age"] as! UInt8),
                                 name: $0["name"] as! String,
                                 symbol: $0["symbol"] as! String,
                                 count: $0["count"] as! UInt8
                    )
                } else {
                    return ArgsX(innerArgs: $0["innerArgs"] as! InnerArgs,
                                 name: $0["name"] as! String,
                                 symbol: $0["symbol"] as! String,
                                 count: $0["count"] as! UInt8
                    )
                }
            },
            description: "ArgsX"
        )
        
 
                
        let expected = BeetArgsStruct(fields: [
            ("innerArgs", innerStruct.toFixedFromValue(val: ["housePrices": [], "age": UInt8(20)])),
            ("name", FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: 5)))),
            ("symbol", FixedSizeBeet(value: .collection(FixedSizeUtf8String(stringByteLength: 3)))),
            ("count", FixedSizeBeet(value: .scalar(u8())))
        ], description: "Argsx")
        
        verify(beet: argStruct,
               args: ["innerArgs": ["housePrices": [], "age": UInt8(20)],
                                       "name": "ABC",
                                       "count": UInt8(2),
                                       "symbol": "CCC"
                                    ],
               expected: expected)
    }
}
