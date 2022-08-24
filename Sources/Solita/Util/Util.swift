import Foundation
import CommonCrypto
import PathKit

func withoutTsExtension(p: String) -> String {
    return p.replacingOccurrences(of: ".swift", with: "")
}

func canAccess(p: Path) -> Bool{
    return p.exists
}


// -----------------
// Discriminators
// -----------------

/**
 * Number of bytes of the account discriminator.
 */
let ACCOUNT_DISCRIMINATOR_SIZE = 8

/**
 * Calculates and returns a unique 8 byte discriminator prepended to all
 * accounts.
 *
 * @param name The name of the account to calculate the discriminator.
 */
func accountDiscriminator(name: String) -> Data {
    let preimage = "account:\(name.pascalCase.camelized)"
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    let data = preimage.data(using: .utf8)!
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return data.subdata(in: 0..<ACCOUNT_DISCRIMINATOR_SIZE)
}

/**
 * Namespace for global instruction function signatures (i.e. functions
 * that aren't namespaced by the state or any of its trait implementations).
 */
let SIGHASH_GLOBAL_NAMESPACE = "global"

/**
 * Calculates and returns a unique 8 byte discriminator prepended to all instruction data.
 *
 * @param name The name of the instruction to calculate the discriminator.
 */
func instructionDiscriminator(name: String) -> Data {
    return sighash(nameSpace: SIGHASH_GLOBAL_NAMESPACE, ixName: name)
}

func sighash(nameSpace: String, ixName: String) -> Data {
    let name = snakeCased(string: ixName)
    let preimage = "\(nameSpace):\(name)"
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    let data = preimage.data(using: .utf8)!
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return data.subdata(in: 0..<8)
}

func snakeCased(string: String) -> String {
    let pattern = "([a-z0-9])([A-Z])"
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: string.count)
    return regex!.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "$1_$2").lowercased()
}

func anchorDiscriminatorField(name: String) -> IdlField{
    let ty: IdlType = .idlTypeArray(IdlTypeArray(array: [IdlTypeArrayInner(idlType: .beetTypeMapKey(.numbersTypeMapKey(.u8)), size: 8)]))
    return IdlField(name: name, type: ty, attrs: nil)
}

public func anchorDiscriminatorType(
    typeMapper: TypeMapper,
    context: String
) -> String {
    let ty: IdlType = .idlTypeArray(IdlTypeArray(array: [IdlTypeArrayInner(idlType: .beetTypeMapKey(.numbersTypeMapKey(.u8)), size: 8)]))
    return typeMapper.map(ty: ty, name: context)
}

private extension String {
    var pascalCase: String {
        return self.components(separatedBy: " ")
            .map {
                if $0.count <= 3 {
                    return $0.uppercased()
                } else {
                    if $0.firstIndex(of: "-") != nil {
                        return $0.components(separatedBy: "-").map { $0.pascalCase }.joined(separator: "-")
                    } else {
                        return $0.capitalized
                    }
                }
            }
            .joined(separator: " ")
    }
    var uppercasingFirst: String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    var lowercasingFirst: String {
        return prefix(1).lowercased() + dropFirst()
    }
    
    var camelized: String {
        guard !isEmpty else {
            return ""
        }
        
        let parts = self.components(separatedBy: " ")
        
        let first = String(describing: parts.first!).lowercasingFirst
        let rest = parts.dropFirst().map({String($0).uppercasingFirst})
        
        return ([first] + rest).joined(separator: "")
    }
}
