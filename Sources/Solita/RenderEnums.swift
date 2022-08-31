import Foundation

public func renderScalarEnum(
    name: String,
    variants: [String],
    includePublic: Bool
) -> String {
    var casedValueVariants: [String] = []
    var casedVariantsRawValues: [String] = []
    for i in variants.indices {
        let variant = variants[i]
        casedValueVariants.append("case \(i) : self = .\(variant)")
        casedVariantsRawValues.append("case .\(variant) : return \(i)")
    }
    return
"""
/**
 * @category enums
 * @category generated
 */
\(includePublic ? "public " : "")enum \(name) {
    case \(variants.joined(separator: ", "))
}

extension \(name) : CaseIterable & RawRepresentable {
    \(includePublic ? "public " : "") typealias RawValue = UInt8

    \(includePublic ? "public " : "") init?(rawValue: UInt8) {
        switch rawValue {
        \(casedValueVariants.joined(separator: "\n        "))
        default : return nil
        }
    }
    
    \(includePublic ? "public " : "") var rawValue: UInt8 {
        switch self {
        \(casedVariantsRawValues.joined(separator: "\n        "))
        }
    }
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
