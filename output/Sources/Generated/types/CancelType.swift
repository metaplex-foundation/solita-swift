import Beet

/**
 * @category enums
 * @category generated
 */
public enum CancelType {
    case Cancel, AuctioneerCancel
}

extension CancelType : CaseIterable & RawRepresentable {
    public  typealias RawValue = UInt8

    public  init?(rawValue: UInt8) {
        switch rawValue {
        case 0 : self = .Cancel
        case 1 : self = .AuctioneerCancel
        default : return nil
        }
    }
    
    public  var rawValue: UInt8 {
        switch self {
        case .Cancel : return 0
        case .AuctioneerCancel : return 1
        }
    }
}

/**
 * @category userTypes
 * @category generated
 */
public let cancelTypeBeet = FixedSizeBeet(value: .scalar( FixedScalarEnum<CancelType>() ))
public let cancelTypeBeetWrapped = Beet.fixedBeet(cancelTypeBeet)