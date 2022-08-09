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
            let size: UInt32 = u32().read(buf: buf, offset: mutableoffset)
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

/**
 * De/Serializes an array with a specific number of elements of type {@link T}
 * which do not all have the same size.
 *
 * @template T type of elements held in the array
 *
 * @param elements the De/Serializers for the element types
 * @param elementsByteSize size of all elements in the array combined
 *
 * @category beet/collection
 */

class FixedSizeArray<V>: ElementCollectionFixedSizeBeet {
    var length: UInt32
    var lenPrefixByteSize: UInt = 4
    let description: String
    let byteSize: UInt
    let elements: [FixedSizeBeet]
    var elementByteSize: UInt
    let firstElement: String
    
    init(elements: [FixedSizeBeet], elementsByteSize: Int32){
        self.elements = elements
        self.elementByteSize = UInt(elementsByteSize)
        self.length = UInt32(elements.count)
        switch elements.first?.value {
        case .scalar(let type):
            firstElement = type.description
        case .collection(let type):
            firstElement = type.description
        case .none:
            firstElement = "<EMPTY>"
        }
        
        self.description = "Array<\(firstElement)>(\(length)[ 4 + \(elementsByteSize)]"
        self.byteSize = UInt(4 + elementsByteSize)
    }
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        let x = value as! [V]
        assert(x.count == length, "array length \(x.count) should match len \(length)")
        u32().write(buf: &buf, offset: offset, value: UInt32(length))
        
        var cursor: UInt = UInt(offset + 4)
        for i in 0..<Int(length) {
            let element = elements[i]
            switch element.value {
            case .scalar(let type):
                type.write(buf: &buf, offset: Int(cursor), value: x[i])
                cursor += type.byteSize
            case .collection(let type):
                type.write(buf: &buf, offset: Int(cursor), value: x[i])
                cursor += type.byteSize
            }
            
        }
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
        let size: UInt32 = u32().read(buf: buf, offset: offset)
        assert(size == length, "invalid byte size")
        
        var cursor: UInt = UInt(offset + 4)
        var arr: [V] = []
        for i in 0..<Int(length) {
            let element = elements[i]
            switch element.value {
            case .scalar(let type):
                arr.append(type.read(buf: buf, offset: Int(cursor)))
                cursor += type.byteSize
            case .collection(let type):
                arr.append(type.read(buf: buf, offset: Int(cursor)))
                cursor += type.byteSize
            }
        }
        return arr as! T
    }
}

/**
 * Wraps an array De/Serializer with with elements of type {@link T} which do
 * not all have the same size.
 *
 * @template T type of elements held in the array
 *
 * @param element the De/Serializer for the element types
 *
 * @category beet/collection
 */
class array: FixableBeet {

    let element: Beet
    let description: String = "array"

    init(element: Beet){
        self.element = element
    }
    
    func toFixedFromData(buf: Data, offset: Int) -> FixedSizeBeet {
        let len: UInt32 = u32().read(buf: buf, offset: offset)
        let cursorStart = offset + 4
        var cursor = cursorStart

        var fixedElements: [FixedSizeBeet] = []
        for _ in 0..<len {
            let fixedElement = fixBeetFromData(beet: element, buf: buf, offset: offset)
            fixedElements.append(fixedElement)
            switch fixedElement.value {
            case .collection(let type):
                cursor += Int(type.byteSize)
            case .scalar(let type):
                cursor += Int(type.byteSize)
            }
        }
        return FixedSizeBeet(value: .collection(FixedSizeArray<Any>(elements: fixedElements, elementsByteSize: Int32(cursor) - Int32(cursorStart))))
    }
    
    func toFixedFromValue(val: Any) -> FixedSizeBeet {
        let v = val as! [Any]
        var elementsSize = 0
        var fixedElements: [FixedSizeBeet] = []
        for i in 0..<v.count {
            let fixedElement = fixBeetFromValue(beet: element, val: v[i])
            fixedElements.append(fixedElement)
            
            switch fixedElement.value {
            case .collection(let type):
                elementsSize += Int(type.byteSize)
            case .scalar(let type):
                elementsSize += Int(type.byteSize)
            }
        }
        return FixedSizeBeet(value: .collection(FixedSizeArray<Any>(elements: fixedElements, elementsByteSize: Int32(elementsSize))))
    }
}

/**
 * A De/Serializer for raw {@link Buffer}s that just copies/reads the buffer bytes
 * to/from the provided buffer.
 *
 * @param bytes the byte size of the buffer to de/serialize
 * @category beet/collection
 */
class FixedSizeBuffer: ScalarFixedSizeBeet{
    let description: String
    let byteSize: UInt
    let bytes: UInt
    init(bytes: UInt){
        self.bytes = bytes
        self.byteSize = bytes
        self.description = "Buffer (\(bytes))"
    }
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        var advanced = buf
        let data = value as! Data
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
        return buf.subdata(in: offset..<(offset + Int(bytes))) as! T
    }
}

/**
 * A De/Serializer for {@link Uint8Array}s of known size that just copies/reads
 * the array bytes to/from the provided buffer.
 *
 * @category beet/collection
 */
class FixedSizeUint8Array: ScalarFixedSizeBeet {
    let description: String
    let byteSize: UInt
    let len: UInt
    let lenPrefix: Bool
    let arrayBufferBeet: FixedSizeBuffer
    init(len: UInt, lenPrefix: Bool = false){
        self.lenPrefix = lenPrefix
        self.len = len
        self.description = "Uint8Array(\(len)"
        if lenPrefix {
            self.byteSize = len + 4
        } else {
            self.byteSize = len
        }
        self.arrayBufferBeet = FixedSizeBuffer(bytes: len)
    }
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        let d = value as! Data
        var mutableOffset = offset
        assert(d.count == len, "Uint8Array length \(d.count) should match len \(len)")
        if lenPrefix {
            u32().write(buf: &buf, offset: mutableOffset, value: UInt32(len))
            mutableOffset += 4
        }
        let valueBuf = d
        arrayBufferBeet.write(buf: &buf, offset: mutableOffset, value: valueBuf)
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
        var mutableOffset = offset
        if lenPrefix {
            let size: UInt32 = u32().read(buf: buf, offset: mutableOffset)
            assert(size == len, "invalid byte size")
            mutableOffset += 4
        }
        let arrayBuffer: Data = arrayBufferBeet.read(buf: buf, offset: mutableOffset)
        return arrayBuffer as! T
    }
}

/**
 * A De/Serializer for {@link Uint8Array}s that just copies/reads the array bytes
 * to/from the provided buffer.
 *
 * @category beet/collection
 */
class Uint8Array: FixableBeet {
    func toFixedFromData(buf: Data, offset: Int) -> FixedSizeBeet {
        let len: UInt32 = u32().read(buf: buf, offset: offset)
        return FixedSizeBeet(value: .scalar(FixedSizeUint8Array(len: UInt(len), lenPrefix: true)))
    }
    
    func toFixedFromValue(val: Any) -> FixedSizeBeet {
        let d = val as! Data
        let len = d.count
        return FixedSizeBeet(value: .scalar(FixedSizeUint8Array(len: UInt(len), lenPrefix: true)))
    }
    
    var description: String = "Uint8Array"
}
