import Foundation

/**
 * De/serializer for enums with up to 255 less variants which have no data.
 *
 * @param enumType type of enum to process, i.e. Color or Direction
 *
 * @category beet/enum
 */
public class FixedScalarEnum<C>: ScalarFixedSizeBeet where C: CaseIterable & Equatable & RawRepresentable {
    public let byteSize: UInt = u8().byteSize
    public let description: String = "Enum"
    private let keys: C.AllCases = C.allCases

    public func write<T>(buf: inout Data, offset: Int, value: T) {
        if value is Int {
            u8().write(buf: &buf, offset: offset, value: value)
        } else {
            let e = value as! C
            u8().write(buf: &buf, offset: offset, value: e.rawValue)
        }
    }

    public func read<T>(buf: Data, offset: Int) -> T {
        let uInt: UInt8 = u8().read(buf: buf, offset: offset)
        return C.init(rawValue: uInt as! C.RawValue)! as! T
    }
}

// -----------------
// Uniform Data Enum
// -----------------

/**
 * Represents an {@link Enum} type which contains fixed size data and whose
 * data is uniform across all variants.
 *
 * @template Kind the enum variant, i.e. `Color.Red`
 * @template Data the data value, i.e. '#f00'
 *
 * @category beet/composite
 */
public struct UniformDataEnumData<K: Equatable, D: Equatable>: Equatable {
    let kind: K
    let data: D

    public static func == (lhs: UniformDataEnumData<K, D>, rhs: UniformDataEnumData<K, D>) -> Bool {
        return lhs.kind == rhs.kind
        && lhs.data == rhs.data
    }
}

/**
 * De/Serializes an {@link Enum} that contains a type of data, i.e. a {@link Struct}.
 * The main difference to a Rust enum is that the type of data has to be the
 * same for all enum variants.
 *
 * @template T inner enum data type
 *
 * @param inner the De/Serializer for the data type
 *
 * @category beet/enum
 */
public class UniformDataEnum<K: CaseIterable & Equatable & RawRepresentable, D: Equatable>: ScalarFixedSizeBeet {
    let inner: FixedSizeBeet
    public var description: String
    public let byteSize: UInt

    init(inner: FixedSizeBeet) {
        self.inner = inner
        switch inner.value {
        case .scalar(let type):
            byteSize =  1 + type.byteSize
            description = "UniformDataEnum<\(type.description)>"
        case .collection(let type):
            byteSize =  1 + type.byteSize
            description = "UniformDataEnum<\(type.description)>"
        }
    }

    public func write<T>(buf: inout Data, offset: Int, value: T) {
        let x = value as! UniformDataEnumData<K, D>
        u8().write(buf: &buf, offset: offset, value: x.kind.rawValue)
        switch inner.value {
        case .scalar(let type):
            type.write(buf: &buf, offset: offset + 1, value: x.data)
        case .collection(let type):
            type.write(buf: &buf, offset: offset + 1, value: x.data)
        }
    }

    public func read<T>(buf: Data, offset: Int) -> T {
        let kindRawValue: UInt8 = u8().read(buf: buf, offset: offset)
        let kind = K.init(rawValue: kindRawValue as! K.RawValue)!
        switch inner.value {
        case .scalar(let type):
            let data = type.read(buf: buf, offset: offset + 1) as D
            return UniformDataEnumData<K, D>(kind: kind, data: data) as! T
        case .collection(let type):
            let data = type.read(buf: buf, offset: offset + 1) as D
            return UniformDataEnumData<K, D>(kind: kind, data: data) as! T
        }
    }
}

public enum ParamkeyTypes {
    case key(String)
    case noKey
}
public protocol ConstructableWithDiscriminator {
    init?(discriminator: UInt8, params: [String: Any])
    static func paramsOrderedKeys(discriminator: UInt8) -> [ParamkeyTypes]
    func mirror() -> (label: String, params: [String: Any])
}

extension ConstructableWithDiscriminator {

    func mirror() -> (label: String, params: [String: Any]) {
        mirrored(value: self)
    }
}

// -----------------
// Data Enum
// -----------------
public class EnumDataVariantBeet<E: ConstructableWithDiscriminator>: ScalarFixedSizeBeet {
    public let description: String
    public let byteSize: UInt
    let inner: FixedSizeBeet
    let discriminant: UInt8

    init(inner: FixedSizeBeet, discriminant: UInt8) {
        self.inner = inner
        self.discriminant = discriminant
        switch inner.value {
        case .scalar(let type):
            byteSize =  type.byteSize + u8().byteSize
            description = "EnumData<\(type.description)>"
        case .collection(let type):
            byteSize =  type.byteSize + u8().byteSize
            description = "EnumData<\(type.description)>"
        }
    }

    public func write<T>(buf: inout Data, offset: Int, value: T) {
        u8().write(buf: &buf, offset: offset, value: discriminant)
        let val = value as! E
        let mirror = val.mirror()

        var dictionary: [AnyHashable: Any] = [:]
        for param in mirror.params {
            dictionary[param.key] = param.value
        }
        // If the fixed value is a struct we need to separate it pass the whole dict so keys can match.
        // it is the only whay I found to separate this logic and support same .ts features
        switch inner.value {
        case .scalar(let scalar):
            if scalar is BeetArgsStruct {
                inner.write(buf: &buf, offset: offset + Int(u8().byteSize), value: dictionary)
            } else {
                inner.write(buf: &buf, offset: offset + Int(u8().byteSize), value: mirror.params.values.first)
            }
        case .collection:
            inner.write(buf: &buf, offset: offset + Int(u8().byteSize), value: mirror.params.values.first)
        }

    }

    public func read<T>(buf: Data, offset: Int) -> T {
        let discriminator: UInt8 = u8().read(buf: buf, offset: offset)

        let param: Any = inner.read(buf: buf, offset: offset + Int(u8().byteSize))
        if param is [String: Any] {
            return E.init(discriminator: discriminator, params: param as! [String: Any]) as! T
        } else {
            var dictionary: [String: Any] = [:]
            for paramkeyType in E.paramsOrderedKeys(discriminator: discriminator) {
                switch paramkeyType {
                case .key(let key):
                    dictionary[key] = inner.read(buf: buf, offset: offset + Int(u8().byteSize)) as Any
                case .noKey:
                    dictionary[UUID().uuidString] = inner.read(buf: buf, offset: offset + Int(u8().byteSize)) as Any
                }

            }
            return E.init(discriminator: discriminator, params: dictionary) as! T

        }
    }
}

public class DataEnum<E: ConstructableWithDiscriminator>: FixableBeet {
    public var description: String
    let variants: [DataEnumBeet<E>]

    init(variants: [DataEnumBeet<E>]) {
        self.description = "DataEnum<\(variants.count) variants>"
        self.variants = variants
    }

    public func toFixedFromData(buf: Data, offset: Int) -> FixedSizeBeet {
        let discriminant: UInt8 = u8().read(buf: buf, offset: offset)
        let variant = variants[Int(discriminant)]
        let (_, dataBeet) = variant
        switch dataBeet {
        case .fixedBeet(let type):
            return FixedSizeBeet(value: .scalar(EnumDataVariantBeet<E>(inner: type, discriminant: discriminant)))
        case .fixableBeat(let type):
            return FixedSizeBeet(value: .scalar(EnumDataVariantBeet<E>(inner: type.toFixedFromData(buf: buf, offset: (offset + 1)), discriminant: discriminant)))
        }
    }

    public func toFixedFromValue(val: Any) -> FixedSizeBeet {
        let value = val as! E
        let mirror = mirrored(value: value)
        let variant = self.variants.first { $0.label == mirror.label}!
        let discriminant = self.variants.firstIndex { $0.label == mirror.label }!
        var fixedBeats: [FixedSizeBeet] = []

        switch variant.beet {
        case .fixedBeet(let fixedBeet):
            fixedBeats.append(fixedBeet)
        case .fixableBeat(let fixableBeat):
            for param in mirror.params {
                if fixableBeat is FixableBeetStruct<Args> {
                    fixedBeats.append(fixableBeat.toFixedFromValue(val: val))
                    break
                } else {
                    fixedBeats.append(fixableBeat.toFixedFromValue(val: param.value))
                }
            }
        }

        if fixedBeats.count > 0 {
            return FixedSizeBeet(value: .scalar(EnumDataVariantBeet<E>(inner: fixedBeats.first!, discriminant: UInt8(discriminant))))
        } else {
            return FixedSizeBeet(value: .scalar(EnumDataVariantBeet<E>(inner: FixedSizeBeet(value: .scalar(coptionNone(description: "none"))), discriminant: UInt8(discriminant))))
        }
    }
}

func mirrored(value: Any) -> (label: String, params: [String: Any]) {
    let reflection = Mirror(reflecting: value)
    guard reflection.displayStyle == .enum,
          let associated = reflection.children.first else {
        return ("\(value)", [:])
    }
    let values = Mirror(reflecting: associated.value).children
    var valuesArray = [String: Any]()
    if values.count > 0 {
        for case let item in values where item.label != nil {
            valuesArray[item.label!] = item.value
        }
        return (associated.label!, valuesArray)
    } else {
        valuesArray[associated.label!] = associated.value
        return (associated.label!, valuesArray)
    }
}

public enum EnumsTypeMapKey: String {
    case fixedScalarEnum
    case dataEnum
}

public typealias EnumsTypeMap = (EnumsTypeMapKey, SupportedTypeDefinition)

public let enumsTypeMap: [EnumsTypeMap] = [
    (EnumsTypeMapKey.fixedScalarEnum, SupportedTypeDefinition(beet: "FixedScalarEnum", isFixable: false, sourcePack: BEET_PACKAGE, swift: "FixedScalarEnum<C>", arg: BeetTypeArg.inner, letpack: BEET_PACKAGE)),
    (EnumsTypeMapKey.dataEnum, SupportedTypeDefinition(beet: "DataEnum", isFixable: false, sourcePack: BEET_PACKAGE, swift: "DataEnum<Kind, Inner>", arg: BeetTypeArg.inner, letpack: BEET_PACKAGE))
]
