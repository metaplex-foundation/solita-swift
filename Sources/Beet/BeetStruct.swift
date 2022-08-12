import Foundation

typealias Args = [AnyHashable: Any]
class BeetStruct<Class>: ScalarFixedSizeBeet {
    let TYPE: String = "BeetStruct"
    let fields: [FixedBeetField]
    let description: String
    var byteSize: UInt { getByteSize() }

    let construct: (_ args: Args) -> Class

    init(fields: [FixedBeetField],
         construct: @escaping (_ args: Args) -> Class,
         description: String = "BeetStruct"
    ) {
        self.fields = fields
        self.construct = construct
        self.description = description
    }

    private func getByteSize() -> UInt {
        var acc: UInt = 0
        for field in self.fields {
            switch field.beet.value {
            case .scalar(let type):
                acc = acc + type.byteSize
            case .collection(let type):
                acc = acc + type.byteSize
            }
        }
        return acc
    }

    /**
     * Along with `read` this allows structs to be treated as {@link Beet}s and
     * thus supports composing/nesting them the same way.
     * @private
     */
    func write<T>(buf: inout Data, offset: Int, value: T) {
        let (innerBuf, innerOffset) = self.serialize(instance: value as! Class)
        var advanced = buf
        let data = innerBuf.bytes[0..<innerOffset]
        advanced.replaceSubrange(offset..<offset+data.count, with: data)
        buf = advanced
    }

    /**
     * Along with `write` this allows structs to be treated as {@link Beet}s and
     * thus supports composing/nesting them the same way.
     * @private
     */
    func read<T>(buf: Data, offset: Int) -> T {
        let k: (Class, Int) = self.deserialize(buffer: buf, offset: offset)
        return k.0 as! T
    }

    /**
     * Deserializes an instance of the Class from the provided buffer starting to
     * read at the provided offset.
     *
     * @returns `[instance of Class, offset into buffer after deserialization completed]`
     */
    func deserialize(buffer: Data, offset: Int = 0) -> (Class, Int) {
        let reader = BeetReader(buffer: buffer, offset: offset)
        let args = reader.readStruct(fields: self.fields) as Args
        return (self.construct(args), reader.offset())
    }

    /**
     * Serializes the provided instance into a new {@link Buffer}
     *
     * @param instance of the struct to serialize
     * @param byteSize allows to override the size fo the created Buffer and
     * defaults to the size of the struct to serialize
     */
    func serialize(instance: Class, byteSize: Int?=nil) -> (Data, Int) {
        let writer = BeetWriter(byteSize: byteSize ?? Int(self.byteSize))
        writer.writeStruct(instance: instance, fields: self.fields)
        return (writer.buffer(), writer.offset())
    }

    func type() -> String {
        return TYPE
    }
}

class BeetArgsStruct: BeetStruct<Args> {
    init(fields: [FixedBeetField],
         description: String = "BeetArgsStruct"
    ) {
        super.init(fields: fields) { args in
            args
        }
    }
}
