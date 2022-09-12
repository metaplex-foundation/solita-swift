import Beet

/**
 * @category enums
 * @category generated
 */
public enum ListingType {
    case Sell, AuctioneerSell
}

extension ListingType : CaseIterable & RawRepresentable {
    public  typealias RawValue = UInt8

    public  init?(rawValue: UInt8) {
        switch rawValue {
        case 0 : self = .Sell
        case 1 : self = .AuctioneerSell
        default : return nil
        }
    }
    
    public  var rawValue: UInt8 {
        switch self {
        case .Sell : return 0
        case .AuctioneerSell : return 1
        }
    }
}

/**
 * @category userTypes
 * @category generated
 */
public let listingTypeBeet = FixedSizeBeet(value: .scalar( FixedScalarEnum<ListingType>() ))
public let listingTypeBeetWrapped = Beet.fixedBeet(listingTypeBeet)