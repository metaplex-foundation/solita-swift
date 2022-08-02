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
    private let keys: C.AllCases
    
    init(){
        keys = C.allCases
    }
    
    func write<T>(buf: inout Data, offset: Int, value: T) {
        if (value is Int) {
            u8().write(buf: &buf, offset: offset, value: value)
        } else {
            let enumValue: Int = keys.firstIndex{ $0 == value as! C }! as! Int
            u8().write(buf: &buf, offset: offset, value: UInt8(enumValue))
        }
    }
    
    func read<T>(buf: Data, offset: Int) -> T {
        let uInt: UInt8 = u8().read(buf: buf, offset: offset)
        return C.init(rawValue: uInt as! C.RawValue) as! T
    }
}
