import Foundation

/**
 * Represents the Rust Option type {@link T}.
 *
 * @template T inner option type
 *
 * @category beet/option
 */
typealias COption<T> = T?

let NONE: UInt8 = 0
let SOME: UInt8 = 1

func isSomeBuffer(buf: Data, offset: Int) -> Bool {
    return buf.bytes[offset] == SOME
}

func isNoneBuffer(buf: Data, offset: Int) -> Bool {
    return buf.bytes[offset] == NONE
}

/**
 * De/Serializes `None` case of an _Option_ of type {@link T} represented by
 * {@link COption}.
 *
 * The de/serialized type is prefixed with `0`.
 * This matches the `COption::None` type borsh representation.
 *
 * @template T inner option type
 * @param inner the De/Serializer for the inner type
 *
 * @category beet/option
 */
class coptionNone: ScalarFixedSizeBeet {
    let description: String
    let byteSize: UInt = 1
    init(description: String ) {
        self.description = "COption<None(\(description)>"
    }

    func write<T>(buf: inout Data, offset: Int, value: T) {
        var mutableBytes = buf.bytes
        mutableBytes[offset] = UInt8(NONE)
        buf = Data(mutableBytes)
    }

    func read<T>(buf: Data, offset: Int) -> T {
        return Optional<Any>.none as! T
    }
}

/**
 * De/Serializes `Some` case of an _Option_ of type {@link T} represented by
 * {@link COption}.
 *
 * The de/serialized type is prefixed with `1`.
 * This matches the `COption::Some` type borsh representation.
 *
 * @template T inner option type
 * @param inner the De/Serializer for the inner type
 *
 * @category beet/composite
 */
class coptionSome: ScalarFixedSizeBeet {
    let description: String
    let byteSize: UInt
    let inner: FixedSizeBeet

    init(inner: FixedSizeBeet) {
        self.inner = inner
        switch inner.value {
        case .scalar(let type):
            byteSize =  1 + type.byteSize
            description = "COption<Some(\(type.description)>[1 + \(type.byteSize)]"
        case .collection(let type):
            byteSize =  1 + type.byteSize
            description = "COption<Some(\(type.description)>[1 + \(type.byteSize)]"
        }
    }

    func write<T>(buf: inout Data, offset: Int, value: T) {
        if case Optional<Any>.none = value as Any {
            assertionFailure("coptionSome cannot handle `nil` values")
        }
        var mutableBytes = buf.bytes
        mutableBytes[offset] = UInt8(SOME)
        buf = Data(mutableBytes)
        switch inner.value {
        case .scalar(let type):
            type.write(buf: &buf, offset: offset + 1, value: value)
        case .collection(let type):
            type.write(buf: &buf, offset: offset + 1, value: value)
        }
    }

    func read<T>(buf: Data, offset: Int) -> T {
        switch inner.value {
        case .scalar(let type):
            return type.read(buf: buf, offset: offset + 1)
        case .collection(let type):
            return type.read(buf: buf, offset: offset + 1)
        }
    }
}

/**
 * De/Serializes an _Option_ of type {@link T} represented by {@link COption}.
 *
 * The de/serialized type is prefixed with `1` if the inner value is present
 * and with `0` if not.
 * This matches the `COption` type borsh representation.
 *
 * @template T inner option type
 * @param inner the De/Serializer for the inner type
 *
 * @category beet/composite
 */
class coption: FixableBeet {
    let  description: String
    let inner: Beet
    init(inner: Beet) {
        self.inner = inner
        switch inner {
        case .fixedBeet(let beet):
            switch beet.value {
            case .scalar(let type):
                self.description = "COption<\(type.description)>"
            case .collection(let type):
                self.description = "COption<\(type.description)>"
            }
        case .fixableBeat(let beet):
            self.description = "COption<\(beet.description)>"
        }
    }

    func toFixedFromData(buf: Data, offset: Int) -> FixedSizeBeet {
        if isSomeBuffer(buf: buf, offset: offset) {
            let innerFixed = fixBeetFromData(beet: inner, buf: buf, offset: offset + 1)
            return FixedSizeBeet(value: .scalar(coptionSome(inner: innerFixed)))
        } else {
            assert(isNoneBuffer(buf: buf, offset: offset), "Expected \(buf) to hold a COption")
            switch inner {
            case .fixedBeet(let beet):
                switch beet.value {
                case .scalar(let type):
                    return FixedSizeBeet(value: .scalar(coptionNone(description: type.description)))
                case .collection(let type):
                    return FixedSizeBeet(value: .scalar(coptionNone(description: type.description)))
                }
            case .fixableBeat(let beet):
                return FixedSizeBeet(value: .scalar(coptionNone(description: beet.description)))
            }
        }
    }

    func toFixedFromValue(val: Any) -> FixedSizeBeet {
        if case Optional<UInt8>.none = val {
            switch inner {
            case .fixedBeet(let beet):
                switch beet.value {
                case .scalar(let type):
                    return FixedSizeBeet(value: .scalar(coptionNone(description: type.description)))
                case .collection(let type):
                    return FixedSizeBeet(value: .scalar(coptionNone(description: type.description)))
                }
            case .fixableBeat(let beet):
                return FixedSizeBeet(value: .scalar(coptionNone(description: beet.description)))
            }
        } else {
            return FixedSizeBeet(value: .scalar(coptionSome(inner: fixBeetFromValue(beet: inner, val: val))))
        }
    }
}

public enum CompositesTypeMapKey: String {
    case option
}

public typealias CompositesTypeMap = (CompositesTypeMapKey, SupportedTypeDefinition)

public let compositesTypeMap: [CompositesTypeMap] = [
    (CompositesTypeMapKey.option, SupportedTypeDefinition(beet: "coption", isFixable: true, sourcePack: BEET_PACKAGE, swift: "COption<Inner>", arg: BeetTypeArg.inner, letpack: BEET_PACKAGE)),
]
