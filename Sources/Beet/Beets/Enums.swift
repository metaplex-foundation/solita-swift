import Foundation


/**
 * De/serializer for enums with up to 255 less variants which have no data.
 *
 * @param enumType type of enum to process, i.e. Color or Direction
 *
 * @category beet/enum
 */
class FixedScalarEnum<C>: ScalarFixedSizeBeet where C : CaseIterable & Equatable & RawRepresentable {
    let byteSize: UInt = u8().byteSize
    let description: String = "Enum"
    private let keys: C.AllCases = C.allCases
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        if (value is Int) {
            u8().write(buf: &buf, offset: offset, value: value)
        } else {
            let e = value as! C
            u8().write(buf: &buf, offset: offset, value: e.rawValue)
        }
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
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
struct UniformDataEnumData<K: Equatable, D: Equatable>: Equatable {
    let kind: K
    let data: D
    
    static func == (lhs: UniformDataEnumData<K, D>, rhs: UniformDataEnumData<K, D>) -> Bool {
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
class UniformDataEnum<K: CaseIterable & Equatable & RawRepresentable, D: Equatable>: ScalarFixedSizeBeet {
    let inner: FixedSizeBeet
    var description: String
    let byteSize: UInt
    
    init(inner: FixedSizeBeet){
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
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        let x = value as! UniformDataEnumData<K,D>
        u8().write(buf: &buf, offset: offset, value: x.kind.rawValue)
        switch inner.value {
        case .scalar(let type):
            type.write(buf: &buf, offset: offset + 1, value: x.data)
        case .collection(let type):
            type.write(buf: &buf, offset: offset + 1, value: x.data)
        }
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
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

// -----------------
// Data Enum
// -----------------
class EnumDataVariantBeet: ScalarFixedSizeBeet{
    let description: String
    let byteSize: UInt
    let inner: FixedSizeBeet
    let discriminant: UInt8
    
    init(inner: FixedSizeBeet, discriminant: UInt8){
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

    func write<T>(buf: inout Data, offset: Int, value: T) {
        u8().write(buf: &buf, offset: offset, value: discriminant)
        switch inner.value {
        case .scalar(let type):
            type.write(buf: &buf, offset: offset + Int(u8().byteSize), value: value)
        case .collection(let type):
            type.write(buf: &buf, offset: offset + Int(u8().byteSize), value: value)
        }
        
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
        switch inner.value {
        case .scalar(let type):
            return type.read(buf: buf, offset: offset + Int(u8().byteSize))
        case .collection(let type):
            return type.read(buf: buf, offset: offset + Int(u8().byteSize))
        }
        
    }
}
