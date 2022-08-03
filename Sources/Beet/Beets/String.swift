import Foundation
import Solana
import XCTest

/**
 * De/Serializes a UTF8 string of a particular size.
 *
 * @param stringByteLength the number of bytes of the string
 *
 * @category beet/collection
 */
class FixedSizeUtf8String: ScalarFixedSizeBeet {
    let stringByteLength: UInt
    let byteSize: UInt
    let length: UInt
    let elementByteSize: UInt = 1
    let lenPrefixByteSize: UInt = 4
    let description: String
    
    init(stringByteLength: UInt){
        self.length = stringByteLength
        self.stringByteLength = stringByteLength
        self.byteSize = stringByteLength + 4
        self.description = "Utf8String(4 + \(stringByteLength)}"
    }
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let string = value as! String
        let data = Data(string.utf8)
        assert(data.count == stringByteLength, "\(string) has invalid byte size")
        u32().write(buf: &advanced, offset: offset, value: UInt32(data.count))
        advanced.replaceSubrange((offset+4)..<(offset+4+data.count), with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
        let size: UInt32 = u32().read(buf: buf, offset: offset)
        assert(size == stringByteLength, "invalid byte size")
        let stringSlice = buf.bytes[(offset+4)..<(offset+4+Int(stringByteLength))]
        return String(data: Data(stringSlice), encoding: .utf8) as! T
    }
}

/**
 * De/Serializes a UTF8 string of any size.
 *
 * @category beet/collection
 */
class Utf8String: FixableBeet {
    func toFixedFromData(buf: Data, offset: Int) -> FixedSizeBeet {
        let size: UInt32 = u32().read(buf: buf, offset: offset)
        return .init(value: .scalar(FixedSizeUtf8String(stringByteLength: UInt(size))))
    }
    
    func toFixedFromValue(val: Any) -> FixedSizeBeet {
        let value = val as! String
        let data = Data(value.utf8)
        return .init(value: .scalar(FixedSizeUtf8String(stringByteLength: UInt(data.count))))
    }
    
    var description: String = "Utf8String"
}
