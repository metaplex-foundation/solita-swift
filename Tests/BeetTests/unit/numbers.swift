//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 7/28/22.
//

import Foundation
import XCTest
@testable import Beet
import Solana

func checkCases<U: Equatable>(
    offsets: [Int],
    cases: [U],
    beet: FixedSizeBeet
) {
    for offset in offsets {
        for x in cases {
            print("Input: \(x)")
            print("Offset: \(offset)")
            
            let byteSize: UInt
            
            switch beet.value {
            case .scalar(let type):
                byteSize = type.byteSize
            case .collection(let type):
                byteSize = type.byteSize
            }
        
            var buf = Data(count: offset + Int(byteSize) + offset)

            switch beet.value {
            case .scalar(let type):
                type.write(buf: &buf, offset: offset, value: x)
            case .collection(let type):
                type.write(buf: &buf, offset: offset, value: x)
            }
            
            print("Buff: \(buf)")
            
            var n: U
            switch beet.value {
            case .scalar(let type):
                n = type.read(buf: buf, offset: offset)
            case .collection(let type):
                n = type.read(buf: buf, offset: offset)
            }
            print("N: \(n)")
            XCTAssertEqual(x, n)
        }
    }
}


final class numberTests: XCTestCase {
    func testNumbersRoundTripU8() {
        let cases: [UInt8] = [0, 1, 100, 0xff]
        let offsets: [Int] = [0, Int(u8().byteSize), 2 * Int(u8().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(u8()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripU16() {
        let cases: [UInt16] = [0, 1, 0xff, 0xffff]
        let offsets: [Int] = [0, Int(u16().byteSize), 2 * Int(u16().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(u16()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripU32() {
        let cases: [UInt32] = [0, 0xff, 0xffff, 0xffffffff]
        let offsets: [Int] = [0, Int(u32().byteSize), 2 * Int(u32().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(u32()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripU64() {
        let cases: [UInt64] = [0, 0xff, 0xffff, 0xffffffff, 18446744073709551615]
        let offsets: [Int] = [0, Int(u64().byteSize), 2 * Int(u64().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(u64()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripU128() {
        let cases: [UInt128] = [
            0,
            0xff,
            0xffff,
            0xffffffff,
            UInt128(stringLiteral: "18446744073709551615"),
            UInt128(stringLiteral: "340282366920938463463374607431768211455")
        ]
        let offsets: [Int] = [0, Int(u128().byteSize), 2 * Int(u128().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(u128()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripU256() {
        let cases: [UInt256] = [
            0,
            0xff,
            0xffff,
            0xffffffff,
            UInt256(stringLiteral: "18446744073709551615"),
            UInt256(stringLiteral: "340282366920938463463374607431768211455"),
            UInt256(stringLiteral: "115792089237316195423570985008687907853269984665640564039457584007913129639935"),
        ]
        let offsets: [Int] = [0, Int(u256().byteSize), 2 * Int(u256().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(u256()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripU512() {
        let cases: [UInt512] = [
            0,
            0xff,
            0xffff,
            0xffffffff,
            UInt512(stringLiteral: "18446744073709551615"),
            UInt512(stringLiteral: "340282366920938463463374607431768211455"),
            UInt512(stringLiteral: "115792089237316195423570985008687907853269984665640564039457584007913129639935"),
            UInt512("13407807929942597099574024998205846127479365820592393377723561443721764030073546976801874298166903427690031858186486050853753882811946569946433649006084095")
        ]
        let offsets: [Int] = [0, Int(u512().byteSize), 2 * Int(u512().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(u512()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripI8() {
        let cases: [Int8] = [0, 1, -1, 100, -100, 0x7f, -0x80]
        let offsets: [Int] = [0, Int(i8().byteSize), 2 * Int(i8().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(i8()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripI16() {
        let cases: [Int16] = [0, 1, -1, 0x7f, -0x80, 0x7fff, -0x8000]
        let offsets: [Int] = [0, Int(u16().byteSize), 2 * Int(u16().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(i16()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripI64() {
        let cases: [Int64] = [
            0,
            -0xff,
            0xff,
            0xffff,
            -0xffff,
            0xffffffff,
            -0xffffffff,
            9223372036854775807,
            -9223372036854775808,
        ]
        let offsets: [Int] = [0, Int(i64().byteSize), 2 * Int(i64().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(i64()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripI128() {
        let cases: [Int128] = [
            0,
            Int128("-4294967295"),
            0xff,
            0xffff,
            Int128("-65535"),
            0xffffffff,
            Int128("-4294967295"),
            Int128("9223372036854775807"),
            Int128("-9223372036854775808"),
            Int128("170141183460469231731687303715884105727"),
            Int128("-170141183460469231731687303715884105728"),
        ]
        let offsets: [Int] = [0, Int(i128().byteSize), 2 * Int(i128().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(i128()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testNumbersRoundTripI256() {
        let cases: [Int256] = [
            0,
            Int256("-4294967295"),
            0xff,
            0xffff,
            Int256("-65535"),
            0xffffffff,
            Int256("-4294967295"),
            Int256("9223372036854775807"),
            Int256("-9223372036854775808"),
            Int256("170141183460469231731687303715884105727"),
            Int256("-170141183460469231731687303715884105728"),
            Int256("-170141183460469231731687303715884105728") * Int256("-170141183460469231731687303715884105728"),
            Int256("-170141183460469231731687303715884105728") * Int256("170141183460469231731687303715884105727")
        ]
        let offsets: [Int] = [0, Int(i256().byteSize), 2 * Int(i256().byteSize)]
        let beet = FixedSizeBeet(value: .scalar(i256()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
}
