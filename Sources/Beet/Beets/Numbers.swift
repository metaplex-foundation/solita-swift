import Foundation
import Solana

/**
 * De/Serializer for 8-bit unsigned integers aka `u8`.
 *
 * @category beet/primitive
 */
public class u8: ScalarFixedSizeBeet {
    public let byteSize: UInt = 1
    public let description: String = "u8"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let uint = value as! UInt8
        let data = uint.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let x = Data(buf.bytes[offset..<(offset + Int(byteSize))]).withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(fromByteOffset: 0, as: UInt8.self)
        })
        debugPrint("read \(description): \(x)")
        return x as! T
    }
}

/**
 * De/Serializer 16-bit unsigned integers aka `u16`.
 *
 * @category beet/primitive
 */
public class u16: ScalarFixedSizeBeet {
    public let byteSize: UInt = 2
    public let description: String = "u16"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf
        let uint = value as! UInt16
        let data = uint.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let x = Data(buf.bytes[offset..<(offset + Int(byteSize))]).withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(fromByteOffset: 0, as: UInt16.self)
        })
        debugPrint("read \(description): \(x)")
        return x as! T
    }
}

/**
 * De/Serializer for 32-bit unsigned integers aka `u32`.
 *
 * @category beet/primitive
 */
public class u32: ScalarFixedSizeBeet {
    public let byteSize: UInt = 4
    public let description: String = "u32"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf
        let uint = value as! UInt32
        let data = uint.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let x = Data(buf.bytes[offset..<(offset + Int(byteSize))]).withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(fromByteOffset: 0, as: UInt32.self)
        })
        debugPrint("read \(description): \(x)")
        return x as! T
    }
}

/**
 * De/Serializer for 64-bit unsigned integers aka `u64`.
 *
 * @category beet/primitive
 */
public class u64: ScalarFixedSizeBeet {
    public let byteSize: UInt = 8
    public let description: String = "u64"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf
        let uint = value as! UInt64
        let data = uint.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let x = buf.withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(fromByteOffset: offset, as: UInt64.self)
        })
        debugPrint("read \(description): \(x)")
        return x as! T
    }
}

/**
 * De/Serializer for 128-bit unsigned integers aka `u128`.
 *
 * @category beet/primitive
 */
public class u128: ScalarFixedSizeBeet {
    public let byteSize: UInt = 16
    public let description: String = "u128"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf

        let bigInt = value as! UInt128
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let bytes = buf.subdata(in: offset..<offset+Int(byteSize)).bytes
        var binaryReader = BinaryReader(bytes: bytes)
        let r = try! UInt128(from: &binaryReader)
        return r as! T
    }
}

/**
 * De/Serializer for 256-bit unsigned integers aka `u256`.
 *
 * @category beet/primitive
 */
public class u256: ScalarFixedSizeBeet {
    public let byteSize: UInt = 32
    public let description: String = "u256"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf

        let bigInt = value as! UInt256
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let bytes = buf.subdata(in: offset..<offset+Int(byteSize)).bytes
        var binaryReader = BinaryReader(bytes: bytes)
        let r = try! UInt256(from: &binaryReader)
        return r as! T
    }
}

/**
 * De/Serializer for 512-bit unsigned integers aka `u512`.
 *
 * @category beet/primitive
 */
public class u512: ScalarFixedSizeBeet {
    public let byteSize: UInt = 64
    public let description: String = "u512"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf

        let bigInt = value as! UInt512
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let bytes = buf.subdata(in: offset..<offset+Int(byteSize)).bytes
        var binaryReader = BinaryReader(bytes: bytes)
        let r = try! UInt512(from: &binaryReader)
        return r as! T
    }
}

// -----------------
// Signed
// -----------------
/**
 * De/Serializer 8-bit signed integers aka `i8`.
 *
 * @category beet/primitive
 */
public class i8: ScalarFixedSizeBeet {
    public let byteSize: UInt = 1
    public let description: String = "i8"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf
        let int = value as! Int8
        let data = int.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let x = Data(buf.bytes[offset..<(offset + Int(byteSize))]).withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(fromByteOffset: 0, as: Int8.self)
        })
        debugPrint("read \(description): \(x)")
        return x as! T
    }
}

/**
 * De/Serializer 16-bit signed integers aka `i16`.
 *
 * @category beet/primitive
 */
public class i16: ScalarFixedSizeBeet {
    public let byteSize: UInt = 2
    public let description: String = "i16"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let int = value as! Int16
        let data = int.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let x = Data(buf.bytes[offset..<(offset + Int(byteSize))]).withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(fromByteOffset: 0, as: Int16.self)
        })
        debugPrint("read \(description): \(x)")
        return x as! T
    }
}

/**
 * De/Serializer 32-bit signed integers aka `i32`.
 *
 * @category beet/primitive
 */
public class i32: ScalarFixedSizeBeet {
    public let byteSize: UInt = 4
    public var description: String = "i32"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let int = value as! Int32
        let data = int.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let x = Data(buf.bytes[offset..<(offset + Int(byteSize))]).withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(fromByteOffset: 0, as: Int32.self)
        })
        debugPrint("read \(description): \(x)")
        return x as! T
    }
}

/**
 * De/Serializer 32-bit signed integers aka `i64`.
 *
 * @category beet/primitive
 */
public class i64: ScalarFixedSizeBeet {
    public let byteSize: UInt = 8
    public let description: String = "i64"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf
        let int = value as! Int64
        let data = int.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let x = Data(buf.bytes[offset..<(offset + Int(byteSize))]).withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(fromByteOffset: 0, as: Int64.self)
        })
        debugPrint("read \(description): \(x)")
        return x as! T
    }
}

// -----------------
// Boolean
// -----------------
/**
 * De/Serializer booleans aka `bool`.
 *
 * @category beet/primitive
 */
public class bool: ScalarFixedSizeBeet {
    public let byteSize: UInt = 1
    public let description: String = "bool"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf
        let bool = value as! Bool
        let data: Data
        if bool {
            data = 1.data()
        } else {
            data = 0.data()
        }
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {

        let x = Data(buf.bytes[offset..<(offset + Int(byteSize))]).withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(fromByteOffset: 0, as: UInt8.self)
        })
        debugPrint("read \(description): \(x)")
        return (x == 1) as! T
    }
}

/**
 * De/Serializer for 128-bit unsigned integers aka `i128`.
 *
 * @category beet/primitive
 */
public class i128: ScalarFixedSizeBeet {
    public let byteSize: UInt = 16
    public let description: String = "i128"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let bigInt = value as! Int128
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {
        let bytes = buf.subdata(in: offset..<offset+Int(byteSize)).bytes
        var binaryReader = BinaryReader(bytes: bytes)
        let r = try! Int128(from: &binaryReader)
        return r as! T
    }
}

/**
 * De/Serializer for 128-bit unsigned integers aka `i256`.
 *
 * @category beet/primitive
 */
public class i256: ScalarFixedSizeBeet {
    public let byteSize: UInt = 32
    public let description: String = "i256"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {

        var advanced = buf

        let bigInt = value as! Int256
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {
        let bytes = buf.subdata(in: offset..<offset+Int(byteSize)).bytes
        var binaryReader = BinaryReader(bytes: bytes)
        let r = try! Int256(from: &binaryReader)
        return r as! T
    }
}

/**
 * De/Serializer for 256-bit unsigned integers aka `i256`.
 *
 * @category beet/primitive
 */
public class i512: ScalarFixedSizeBeet {
    public let byteSize: UInt = 64
    public let description: String = "i256"
    public init(){}
    public func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let bigInt = value as! Int512
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    public func read<T>(buf: Data, offset: Int) -> T {
        let bytes = buf.subdata(in: offset..<offset+Int(byteSize)).bytes
        var binaryReader = BinaryReader(bytes: bytes)
        let r = try! Int512(from: &binaryReader)
        return r as! T
    }
}

extension FixedWidthInteger {
    func data() -> Data {
        let data = withUnsafeBytes(of: self) { Data($0) }
        return data
    }
}

public enum NumbersTypeMapKey: String {
    case u8
    case u16
    case u32
    case u64
    case u128
    case u256
    case u512
    case i8
    case i16
    case i32
    case i64
    case i128
    case i256
    case i512
    case bool
}

public typealias NumbersTypeMap = (NumbersTypeMapKey, SupportedTypeDefinition)

public let numbersTypeMap: [NumbersTypeMap] = [
    (NumbersTypeMapKey.u8, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(u8())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "UInt8")),
    (NumbersTypeMapKey.u16, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(u16())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "UInt16")),
    (NumbersTypeMapKey.u32, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(u32())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "UInt32")),
    (NumbersTypeMapKey.u64, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(u64())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "UInt64")),
    
    (NumbersTypeMapKey.i8, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(i8())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "Int8")),
    (NumbersTypeMapKey.i16, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(i16())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "Int16")),
    (NumbersTypeMapKey.i32, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(i32())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "Int32")),
    (NumbersTypeMapKey.i64, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(i64())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "Int64")),
    (NumbersTypeMapKey.bool, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(bool())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "Bool")),

    (NumbersTypeMapKey.u128, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(u128())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "UInt128")),
    (NumbersTypeMapKey.u256, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(u256())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "UInt256")),
    (NumbersTypeMapKey.u512, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(u512())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "UInt512")),
    (NumbersTypeMapKey.i128, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(i128())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "Int128")),
    (NumbersTypeMapKey.i256, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(i256())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "Int256")),
    (NumbersTypeMapKey.i512, SupportedTypeDefinition(beet: "fixedBeet(.init(value: .scalar(i512())))", isFixable: false, sourcePack: BEET_PACKAGE, swift: "Int512")),
]
