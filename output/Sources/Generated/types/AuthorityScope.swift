import Beet

/**
 * @category enums
 * @category generated
 */
public enum AuthorityScope {
    case Deposit, Buy, PublicBuy, ExecuteSale, Sell, Cancel, Withdraw
}

extension AuthorityScope : CaseIterable & RawRepresentable {
    public  typealias RawValue = UInt8

    public  init?(rawValue: UInt8) {
        switch rawValue {
        case 0 : self = .Deposit
        case 1 : self = .Buy
        case 2 : self = .PublicBuy
        case 3 : self = .ExecuteSale
        case 4 : self = .Sell
        case 5 : self = .Cancel
        case 6 : self = .Withdraw
        default : return nil
        }
    }
    
    public  var rawValue: UInt8 {
        switch self {
        case .Deposit : return 0
        case .Buy : return 1
        case .PublicBuy : return 2
        case .ExecuteSale : return 3
        case .Sell : return 4
        case .Cancel : return 5
        case .Withdraw : return 6
        }
    }
}

/**
 * @category userTypes
 * @category generated
 */
public let authorityScopeBeet = FixedSizeBeet(value: .scalar( FixedScalarEnum<AuthorityScope>() ))
public let authorityScopeBeetWrapped = Beet.fixedBeet(authorityScopeBeet)