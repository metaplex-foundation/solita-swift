import Foundation
import Beet

public enum BeetSolanaTypeMapKey {
    case keysTypeMapKey(KeysTypeMapKey)
    
    public var key: String {
        switch self {
        case .keysTypeMapKey(let key):
            return key.rawValue
        }
    }
}

public var BeetSolanaSupportedTypeMap: Dictionary<String, SupportedTypeDefinition> {
    var supported: Dictionary<String, SupportedTypeDefinition> = [:]
    keysTypeMap.forEach { supported[$0.0.rawValue] = $0.1 }
    return supported
}
