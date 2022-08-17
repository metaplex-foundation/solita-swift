import Foundation

public func renderScalarEnum(
    name: String,
    variants: [String],
    includePublic: Bool
) -> String {
    return
"""
/**
 * @category enums
 * @category generated
 */
\(includePublic ? "public " : "")enum \(name) {
    case \(variants.joined(separator: ", "))
}
"""
}

public func renderScalarEnums(
    map: Dictionary<String, [String]>,
    includePublic: Bool = false
) -> [String] {
    var codes: [String] = []
    for item in map {
        let name = item.key
        let variants = item.value
        codes.append(renderScalarEnum(name: name, variants: variants, includePublic: includePublic))
    }
    return codes
}
