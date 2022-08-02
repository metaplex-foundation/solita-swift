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
        case 0 : self = .red
        case 1 : self = .green
        case 2 : self = .blue
        default : return nil
        }
    }
    
    var rawValue: UInt8 {
        switch self {
        case .red : return 0
        case .green :  return 1
        case .blue : return 2
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
}
