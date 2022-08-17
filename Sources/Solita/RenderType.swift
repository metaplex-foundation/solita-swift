import Foundation

func beetVarNameFromTypeName(ty: String) -> String {
    let camelTyName = ty.first!.lowercased() + ty.dropFirst()
    return "\(camelTyName)Beet"
}
