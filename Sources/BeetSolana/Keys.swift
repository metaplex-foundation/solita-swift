import Foundation
import Beet
import Solana

public let BEET_SOLANA_PACKAGE = "BeetSolana"
public let SOLANA_WEB3_PACKAGE = "Solana"

/**
 * De/Serializer for solana {@link PublicKey}s aka `publicKey`.
 *
 * ## Using PublicKey Directly
 *
 * @category beet/solana
 */
public class BeetPublicKey: ScalarFixedSizeBeet {
    public var description: String = "PublicKey"
    public var byteSize: UInt
    private let beet = FixedSizeUint8Array(len: 32)
    public init(){
        byteSize = beet.byteSize
    }

    public func write<T>(buf: inout Data, offset: Int, value: T) {
        let val = value as! PublicKey
        beet.write(buf: &buf, offset: offset, value: val.data)
    }
    
    public func read<T>(buf: Data, offset: Int) -> T {
        let data: Data = beet.read(buf: buf, offset: offset)
        return PublicKey(data: data) as! T
    }
}

public enum KeysTypeMapKey: String {
    case publicKey
}

public typealias KeysTypeMap = (KeysTypeMapKey, SupportedTypeDefinition)

public let keysTypeMap: [KeysTypeMap] = [
    (KeysTypeMapKey.publicKey, SupportedTypeDefinition(beet: "Beet.fixedBeet(.init(value: .scalar(BeetPublicKey())))", isFixable: false, sourcePack: BEET_SOLANA_PACKAGE, swift: "PublicKey", letpack: SOLANA_WEB3_PACKAGE)),
]
