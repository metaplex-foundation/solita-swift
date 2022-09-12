import Beet

/**
 * @category enums
 * @category generated
 */
public enum BidType {
    case PublicSale, PrivateSale, AuctioneerPublicSale, AuctioneerPrivateSale
}

extension BidType : CaseIterable & RawRepresentable {
    public  typealias RawValue = UInt8

    public  init?(rawValue: UInt8) {
        switch rawValue {
        case 0 : self = .PublicSale
        case 1 : self = .PrivateSale
        case 2 : self = .AuctioneerPublicSale
        case 3 : self = .AuctioneerPrivateSale
        default : return nil
        }
    }
    
    public  var rawValue: UInt8 {
        switch self {
        case .PublicSale : return 0
        case .PrivateSale : return 1
        case .AuctioneerPublicSale : return 2
        case .AuctioneerPrivateSale : return 3
        }
    }
}

/**
 * @category userTypes
 * @category generated
 */
public let bidTypeBeet = FixedSizeBeet(value: .scalar( FixedScalarEnum<BidType>() ))
public let bidTypeBeetWrapped = Beet.fixedBeet(bidTypeBeet)