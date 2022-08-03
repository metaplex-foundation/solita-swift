import Foundation
import XCTest
@testable import Beet
import Solana

enum Color: CaseIterable {
    case red
    case green
    case blue
}

extension Color : RawRepresentable {
    typealias RawValue = UInt8
    init?(rawValue: UInt8){
        switch rawValue {
        case 11 : self = .red
        case 22 : self = .green
        case 33 : self = .blue
        default : return nil
        }
    }
    
    var rawValue: UInt8 {
        switch self {
        case .red : return 11
        case .green :  return 22
        case .blue : return 33
        }
    }
}

enum Seat: CaseIterable & RawRepresentable {
    typealias RawValue = UInt8
    
    case HU
    case Short
    case Full
    
    init?(rawValue: UInt8) {
        switch rawValue {
        case 0 : self = .HU
        case 1 : self = .Short
        case 2 : self = .Full
        default : return nil
        }
    }
    
    var rawValue: UInt8 {
        switch self {
        case .HU : return 0
        case .Short :  return 1
        case .Full : return 2
        }
    }
}

final class enumTests: XCTestCase {
    func testCompositesEnumColorWithAssignedVariants() {
        let cases: [Color] = [Color.red, Color.green, Color.blue]
        let offsets: [Int] = [0, 4]
        let beet = FixedSizeBeet(value: .scalar(FixedScalarEnum<Color>()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
    
    func testCompositesEnumColorWithDefaultVariants() {
        let cases: [Seat] = [Seat.HU, Seat.Full, Seat.Short]
        let offsets: [Int] = [0, 4]
        let beet = FixedSizeBeet(value: .scalar(FixedScalarEnum<Seat>()))
        checkCases(offsets: offsets, cases: cases, beet: beet)
    }
}
