import Foundation

public class InstructionDiscriminator {
    private let ix: IdlInstruction
    private let fieldName: String
    private let typeMapper: TypeMapper
    public init(ix: IdlInstruction, fieldName: String, typeMapper: TypeMapper){
        self.ix = ix
        self.fieldName = fieldName
        self.typeMapper = typeMapper
    }
    public func renderValue() -> String {
        return "\(instructionDiscriminator(name: self.ix.name).bytes) as [UInt8]"
     }
    
    public func getField() -> IdlField {
        return anchorDiscriminatorField(name: self.fieldName)
    }
    public func renderType() -> String {
      return anchorDiscriminatorType(
        typeMapper: self.typeMapper,
        context: "instruction \(self.ix.name) discriminant type"
      )
    }
}
