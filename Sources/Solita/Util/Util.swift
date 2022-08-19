import Foundation
import CommonCrypto

func withoutTsExtension(p: String) -> String {
    return p.replacingOccurrences(of: ".swift", with: "")
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
