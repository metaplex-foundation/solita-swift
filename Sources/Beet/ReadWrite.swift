import Foundation

/**
 * Underlying writer used to serialize structs.
 *
 * @private
 * @category beet/struct
 */
class BeetWriter {
    private var buf: Data
    private var _offset: Int
    
    init(byteSize: Int){
        self.buf = Data(count: byteSize)
        self._offset = 0
    }
    
    func buffer() -> Data {
        return self.buf
    }
    
    func offset() -> Int {
        return self._offset
    }
    
    func maybeResize(bytesNeeded: Int){
        if (self._offset + bytesNeeded > self.buf.count) {
            assertionFailure("We shouldn't ever need to resize")
        }
        // self.buf = Buffer.concat([this.buf, Buffer.alloc(this.allocateBytes)])
    }
    
    func write<T>(beet: FixedSizeBeet, value: T?) {
        switch beet.value{
        case .scalar(let type):
            self.maybeResize(bytesNeeded: Int(type.byteSize))
            type.write(buf: &self.buf, offset: self._offset, value: value)
            self._offset += Int(type.byteSize)
        case .collection(let type):
            self.maybeResize(bytesNeeded: Int(type.byteSize))
            type.write(buf: &self.buf, offset: self._offset, value: value)
            self._offset += Int(type.byteSize)
        }
      }

    func writeStruct<T>(instance: T, fields: [FixedBeetField]) {
        for field in fields {
            let m = Mirror(reflecting: instance)
            let reflectedField = m.children.first { (label: String?, value: Any) in
                label! == field.type as! String
            }
            self.write(beet: field.beet, value: reflectedField?.value)
        }
    }
}

/**
 * Underlying reader used to deserialize structs.
 *
 * @private
 * @category beet/struct
 */
class BeetReader {
    
    private let buffer: Data
    private var _offset: Int
    
    init(buffer: Data, offset: Int = 0){
        self.buffer = buffer
        self._offset = offset
    }
    
    func offset() -> Int {
        return self._offset
    }
    
    func read<T>(beet: FixedSizeBeet) -> T {
        switch beet.value{
        case .scalar(let type):
            let value: T = type.read(buf: self.buffer, offset: self._offset)
            self._offset += Int(type.byteSize)
            return value
        case .collection(let type):
            let value: T = type.read(buf: self.buffer, offset: self._offset)
            self._offset += Int(type.byteSize)
            return value
        }
    }
    
    func readStruct<T>(fields: [FixedBeetField]) -> Dictionary<AnyHashable, T> {
        var acc: Dictionary<AnyHashable, T> = [:]
        for field in fields{
            acc[field.type] = self.read(beet: field.beet)
        }
        return acc
    }
}
