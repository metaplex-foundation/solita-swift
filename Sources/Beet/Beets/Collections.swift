import Foundation

/**
 * De/Serializes an array with a specific number of elements of type {@link T}
 * which all have the same size.
 *
 * @template T type of elements held in the array
 *
 * @param element the De/Serializer for the element type
 * @param len the number of elements in the array
 * @param lenPrefix if `true` a 4 byte number indicating the size of the array
 * will be included before serialized array data
 *
 * @category beet/collection
 */
class UniformFixedSizeArray<V>: ElementCollectionBeet & ElementCollectionFixedSizeBeet {
    var lenPrefixByteSize: UInt = 4
    let element: FixedSizeBeet
    let byteSize: UInt
    var elementByteSize: UInt
    var length: UInt32
    var description: String
    let lenPrefix: Bool
    
    init(element: FixedSizeBeet, len: UInt32, lenPrefix: Bool = false){
        self.element = element
        
        let byteSize: UInt
        let description: String
        switch element.value {
        case .scalar(let type):
            byteSize = type.byteSize
            description = type.description
        case .collection(let type):
            byteSize = type.byteSize
            description = type.description
        }
        
        self.lenPrefix = lenPrefix
        self.length = len
        self.description = "Array<\(description)>(\(length)"
        self.elementByteSize = byteSize
        let arraySize = byteSize * UInt(len)
        if lenPrefix {
            self.byteSize = 4 + arraySize
        } else {
            self.byteSize = arraySize
        }
    }
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        let x = value as! [V]
        var mutableoffset = offset
        assert(x.count == length, "array length \(x.count) should match len \(length)")
        if (lenPrefix) {
            u32().write(buf: &buf, offset: offset, value: length)
            mutableoffset += 4
        }
        
        switch element.value {
        case .scalar(let type):
            for i in 0..<Int(length) {
                type.write(buf: &buf, offset: mutableoffset + i * Int(type.byteSize), value: x[i])
            }
        case .collection(let type):
            for i in 0..<Int(length) {
                type.write(buf: &buf, offset: mutableoffset + i * Int(type.byteSize), value: x[i])
            }
        }
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
        var mutableoffset = offset
        if lenPrefix {
            let size: UInt32 = u32().read(buf: buf, offset: offset)
            assert(size == length, "invalid byte size")
            mutableoffset += 4
        }
        var arr: [V] = []
        
        switch element.value {
        case .scalar(let type):
            for i in 0..<Int(length) {
                arr.append(type.read(buf: buf, offset: mutableoffset + i * Int(type.byteSize)))
            }
        case .collection(let type):
            for i in 0..<Int(length) {
                arr.append(type.read(buf: buf, offset: mutableoffset + i * Int(type.byteSize)))
            }
        }
        
        
        return arr as! T
    }
}
