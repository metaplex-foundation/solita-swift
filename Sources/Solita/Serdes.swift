import Foundation


public enum SerdePackage: RawRepresentable {
    case BEET_PACKAGE
    case BEET_SOLANA_PACKAGE
    case SOLANA_WEB3_PACKAGE
    
    public typealias RawValue = String
    public init?(rawValue: String) {
        switch rawValue{
        case BEET_PACKAGE_STRING: self = .BEET_PACKAGE
        case BEET_SOLANA_PACKAGE_STRING: self = .BEET_SOLANA_PACKAGE
        case SOLANA_WEB3_PACKAGE_STRING: self = .SOLANA_WEB3_PACKAGE
        default: fatalError("Unkown Package")
        }
    }
    public var rawValue: String {
        switch self {
            case .BEET_PACKAGE: return BEET_PACKAGE_STRING
            case .BEET_SOLANA_PACKAGE: return BEET_SOLANA_PACKAGE_STRING
            case .SOLANA_WEB3_PACKAGE: return SOLANA_WEB3_PACKAGE_STRING
        }
    }
}
public enum SerdePackageExportName: RawRepresentable {
    case BEET_EXPORT_NAME
    case BEET_SOLANA_EXPORT_NAME
    case SOLANA_WEB3_EXPORT_NAME

    public typealias RawValue = String
    public init?(rawValue: String) {
        switch rawValue{
        case BEET_EXPORT_NAME_STRING: self = .BEET_EXPORT_NAME
        case BEET_SOLANA_EXPORT_NAME_STRING: self = .BEET_SOLANA_EXPORT_NAME
        case SOLANA_WEB3_EXPORT_NAME_STRING: self = .SOLANA_WEB3_EXPORT_NAME
        default: fatalError("Unkown Package")
        }
    }
    public var rawValue: String {
        switch self {
            case .BEET_EXPORT_NAME: return BEET_EXPORT_NAME_STRING
            case .BEET_SOLANA_EXPORT_NAME: return BEET_SOLANA_EXPORT_NAME_STRING
            case .SOLANA_WEB3_EXPORT_NAME: return SOLANA_WEB3_EXPORT_NAME_STRING
        }
    }
}


public let serdePackages: Dictionary<SerdePackage, SerdePackageExportName> =
[
    SerdePackage.BEET_PACKAGE: SerdePackageExportName.BEET_EXPORT_NAME,
    SerdePackage.BEET_SOLANA_PACKAGE: SerdePackageExportName.BEET_SOLANA_EXPORT_NAME,
    SerdePackage.SOLANA_WEB3_PACKAGE: SerdePackageExportName.SOLANA_WEB3_EXPORT_NAME,
]

public func serdePackageExportName(
    pack: String?
) -> SerdePackageExportName? {
    
    guard let pack = pack, let serdePackage = SerdePackage(rawValue: pack) else { return nil }
    
    let exportName = serdePackages[serdePackage]
    assert(exportName != nil, "Unknown serde package \(serdePackage.rawValue)")
    return exportName
}

func isKnownSerdePackage(pack: String) -> Bool {
    return (
        pack == BEET_PACKAGE_STRING ||
        pack == BEET_SOLANA_PACKAGE_STRING ||
        pack == SOLANA_WEB3_PACKAGE_STRING
    )
}

func assertKnownSerdePackage(
    pack: String
){
    assert(
        isKnownSerdePackage(pack: pack),
        "\(pack) is an unknown and thus not yet supported de/serializer package"
    )
}
