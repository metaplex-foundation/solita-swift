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
struct UniformDataEnumData {
    let kind: Any
    let data: Any
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
class UniformDataEnum: ScalarFixedSizeBeet {
    let inner: ScalarFixedSizeBeet
    var description: String
    let byteSize: UInt
    
    init(inner: ScalarFixedSizeBeet){
        self.inner = inner
        byteSize =  1 + inner.byteSize
        description = "UniformDataEnum<\(inner.description)>"
    }
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        let x = value as! UniformDataEnumData
        u8().write(buf: &buf, offset: offset, value: x.kind)
        inner.write(buf: &buf, offset: offset + 1, value: x.data)
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
        let kind = u8().read(buf: buf, offset: offset) as Any
        let data = inner.read(buf: buf, offset: offset + 1) as Any
        return UniformDataEnumData(kind: kind, data: data) as! T
    }
}

// -----------------
// Data Enum
// -----------------
class EnumDataVariantBeet: ScalarFixedSizeBeet{
    let description: String
    let byteSize: UInt
    let inner: ScalarFixedSizeBeet
    let discriminant: UInt8
    
    init(inner: ScalarFixedSizeBeet, discriminant: UInt8){
        self.inner = inner
        self.discriminant = discriminant
        byteSize =  inner.byteSize + u8().byteSize
        description = "EnumData<\(inner.description)>"
    }

    func write<T>(buf: inout Data, offset: Int, value: T) {
        u8().write(buf: &buf, offset: offset, value: discriminant)
        inner.write(buf: &buf, offset: offset + Int(u8().byteSize), value: value)
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
        return inner.read(buf: buf, offset: offset + Int(u8().byteSize))
    }
}
