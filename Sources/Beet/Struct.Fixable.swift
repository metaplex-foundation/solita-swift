import Foundation

let FixableBeetStruct_TYPE: String = "FixableBeetStruct"
class FixableBeetStruct<Class>: FixableBeet {
    let fields: [BeetField]
    let description: String
    let construct: (_ args: Args) -> Class
    
    init(fields: [BeetField],
         construct: @escaping (_ args: Args) -> Class,
         description: String = FixableBeetStruct_TYPE
    ){
        self.fields = fields
        self.construct = construct
        self.description = description
    }
    
    /**
     * Deserializes an instance of the Class from the provided buffer starting to
     * read at the provided offset.
     *
     * @returns `[instance of Class, offset into buffer after deserialization completed]`
     */
    func deserialize(buffer: Data, offset: Int = 0) -> (Class, Int) {
        switch self.toFixedFromData(buf: buffer, offset: offset).value {
        case .scalar(let value):
            let beetStruct = value as! BeetStruct<Class>
            return beetStruct.deserialize(buffer: buffer, offset: offset)
        case .collection:
            fatalError("Should not be a collection.")
        }
    }
    
    /**
     * Serializes the provided instance into a new {@link Buffer}
     *
     * **NOTE:** that the `instance` is traversed and each of its fields accessed
     * twice, once to derive a _fixed size_ {@link BeetStruct} and then use it to
     * serialize the `instance`.
     * Therefore ensure that none of the properties that are part of the struct
     * have side effects, i.e. via `Getter`s.
     *
     * @param instance of the struct to serialize
     * @param byteSize allows to override the size fo the created Buffer and
     * defaults to the size of the struct to serialize
     */
    func serialize(instance: Args, byteSize: Int?) -> (Data, Int) {
        switch self.toFixedFromValue(val: instance).value {
        case .scalar(let value):
            let beetStruct = value as! BeetStruct<Class>
            return beetStruct.serialize(instance: beetStruct.construct(instance), byteSize: byteSize)
        case .collection:
            fatalError("Should not be a collection.")
        }
    }
    
    func toFixedFromData(buf: Data, offset: Int) -> FixedSizeBeet {
        var cursor = offset
        var fixedFields: [FixedBeetField] = []
        
        for i in 0..<self.fields.count {
            let (key, beet) = self.fields[i]
            let fixedBeet = fixBeetFromData(beet: beet, buf: buf, offset: cursor)
            fixedFields.append((key, fixedBeet))
            
            switch fixedBeet.value {
            case .scalar(let type):
                cursor += Int(type.byteSize)
            case .collection(let type):
                cursor += Int(type.byteSize)
            }
        }
        if self.description != FixableBeetStruct_TYPE {
            return FixedSizeBeet(value: .scalar(BeetStruct(fields: fixedFields, construct: self.construct, description: description)))
        } else {
            return FixedSizeBeet(value: .scalar(BeetStruct(fields: fixedFields, construct: self.construct)))
        }
    }
    
    func toFixedFromValue(val: Any) -> FixedSizeBeet {
        let value = val as! Args
        let argsKeys = value.keys
        var fixedFields: [FixedBeetField] = []
        
        for i in 0..<self.fields.count {
            let (key, beet) = self.fields[i]
            assert(argsKeys.contains{
                $0 == key
            }, "Value with keys [ \(argsKeys) ] should include struct key '\(key)' but doesn't.")
            let argValue = value[key]
            let fixedBeet = fixBeetFromValue(beet: beet, val: argValue)
            fixedFields.append((key, fixedBeet))
        }
        
        if self.description != FixableBeetStruct_TYPE {
            return FixedSizeBeet(value: .scalar(BeetStruct(fields: fixedFields, construct: self.construct, description: description)))
        } else {
            return FixedSizeBeet(value: .scalar(BeetStruct(fields: fixedFields, construct: self.construct)))
        }
    }
}


class FixableBeetArgsStruct<Class>: FixableBeetStruct<Args> {
    init(fields: [BeetField],
         description: String = "FixableBeetArgsStruct"
    ){
        super.init(fields: fields) { args in
            args
        }
    }
    
    override func toFixedFromData(buf: Data, offset: Int) -> FixedSizeBeet {
        var cursor = offset
        var fixedFields: [FixedBeetField] = []
        
        for i in 0..<self.fields.count {
            let (key, beet) = self.fields[i]
            let fixedBeet = fixBeetFromData(beet: beet, buf: buf, offset: cursor)
            fixedFields.append((key, fixedBeet))
            
            switch fixedBeet.value {
            case .scalar(let type):
                cursor += Int(type.byteSize)
            case .collection(let type):
                cursor += Int(type.byteSize)
            }
        }
        if self.description != FixableBeetStruct_TYPE {
            return FixedSizeBeet(value: .scalar(BeetArgsStruct(fields: fixedFields, description: description)))
        } else {
            return FixedSizeBeet(value: .scalar(BeetArgsStruct(fields: fixedFields)))
        }
    }
    
    override func toFixedFromValue(val: Any) -> FixedSizeBeet {
        let value = val as! Class
        let mirror = mirrored(value: value)
        
        var dictionary: [AnyHashable: Any] = [:]
        for param in mirror.params{
            dictionary[param.key] = param.value
        }
        
        var fixedFields: [FixedBeetField] = []
        for f in fields {
            switch f.beet {
            case .fixedBeet(let type):
                fixedFields.append((f.type, type))
            case .fixableBeat(let type):
                fixedFields.append((f.type, type.toFixedFromValue(val: dictionary[f.type]!)))
            }
        }
        
        return FixedSizeBeet(value: .scalar(BeetArgsStruct(fields: fixedFields)))
    }
}
