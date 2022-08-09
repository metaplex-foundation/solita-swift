import Foundation
import Solana

/**
 * De/Serializer for 8-bit unsigned integers aka `u8`.
 *
 * @category beet/primitive
 */
class u8: ScalarFixedSizeBeet {
    let byteSize: UInt = 1
    let description: String = "u8"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let uint = value as! UInt8
        let data = uint.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

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
class u16: ScalarFixedSizeBeet {
    let byteSize: UInt = 2
    let description: String = "u16"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
        var advanced = buf
        let uint = value as! UInt16
        let data = uint.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

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
class u32: ScalarFixedSizeBeet {
    let byteSize: UInt = 4
    let description: String = "u32"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
        var advanced = buf
        let uint = value as! UInt32
        let data = uint.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

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
class u64: ScalarFixedSizeBeet {
    let byteSize: UInt = 8
    let description: String = "u64"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
        var advanced = buf
        let uint = value as! UInt64
        let data = uint.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

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
class u128: ScalarFixedSizeBeet {
    let byteSize: UInt = 16
    let description: String = "u128"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
        var advanced = buf

        let bigInt = value as! UInt128
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

        
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
class u256: ScalarFixedSizeBeet {
    let byteSize: UInt = 32
    let description: String = "u256"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
        var advanced = buf

        let bigInt = value as! UInt256
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

        
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
class u512: ScalarFixedSizeBeet {
    let byteSize: UInt = 64
    let description: String = "u512"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
        var advanced = buf

        let bigInt = value as! UInt512
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

        
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
class i8: ScalarFixedSizeBeet {
    let byteSize: UInt = 1
    let description: String = "i8"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
        var advanced = buf
        let int = value as! Int8
        let data = int.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

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
class i16: ScalarFixedSizeBeet {
    let byteSize: UInt = 2
    let description: String = "i16"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let int = value as! Int16
        let data = int.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

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
class i32: ScalarFixedSizeBeet {
    let byteSize: UInt = 4
    var description: String = "i32"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let int = value as! Int32
        let data = int.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

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
class i64: ScalarFixedSizeBeet {
    let byteSize: UInt = 8
    let description: String = "i64"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
        var advanced = buf
        let int = value as! Int64
        let data = int.data()
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {

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
class bool: ScalarFixedSizeBeet {
    let byteSize: UInt = 1
    let description: String = "bool"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
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
    
    func read<T>(buf: Data, offset: Int) -> T {

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
class i128: ScalarFixedSizeBeet {
    let byteSize: UInt = 16
    let description: String = "i128"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let bigInt = value as! Int128
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
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
class i256: ScalarFixedSizeBeet {
    let byteSize: UInt = 32
    let description: String = "i256"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
       
        var advanced = buf

        let bigInt = value as! Int256
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
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
class i512: ScalarFixedSizeBeet {
    let byteSize: UInt = 64
    let description: String = "i256"
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let bigInt = value as! Int512
        var data = Data()
        try! bigInt.serialize(to: &data)
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
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
