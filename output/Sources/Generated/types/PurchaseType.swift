import Beet

/**
 * @category enums
 * @category generated
 */
public enum PurchaseType {
    case ExecuteSale, AuctioneerExecuteSale
}

extension PurchaseType : CaseIterable & RawRepresentable {
    public  typealias RawValue = UInt8

    public  init?(rawValue: UInt8) {
        switch rawValue {
        case 0 : self = .ExecuteSale
        case 1 : self = .AuctioneerExecuteSale
        default : return nil
        }
    }
    
    public  var rawValue: UInt8 {
        switch self {
        case .ExecuteSale : return 0
        case .AuctioneerExecuteSale : return 1
        }
    }
}

/**
 * @category userTypes
 * @category generated
 */
public let purchaseTypeBeet = FixedSizeBeet(value: .scalar( FixedScalarEnum<PurchaseType>() ))
public let purchaseTypeBeetWrapped = Beet.fixedBeet(purchaseTypeBeet)