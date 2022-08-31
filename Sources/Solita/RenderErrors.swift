import Foundation

func asHex(_ code: Int) -> String {
    let string = String(code, radix: 16)
    return "0x\(string)"
}

func renderErrorCode(error: IdlError) -> String {
    let codeName = error.code
    let name = error.name
    
    let code = asHex(codeName)
    let className = name.first!.lowercased() + name.dropFirst() + "Error"
    
    return """
/**
 * \(name): '\(code)'
 *
 * @category Errors
 * @category generated
 */
    case \(className) = "\(code)"
"""
}

func renderError(error: IdlError) -> String {
    let name = error.name
    let msg = error.msg ?? ""
    
    let className = name.first!.lowercased() + name.dropFirst() + "Error"
    
    return """
/**
 * \(name): '\(msg)'
 *
 * @category Errors
 * @category generated
 */
    case .\(className): return "\(msg)"
"""
}

func renderErrors(program: String, errors: [IdlError]) -> String? {
    if errors.count == 0 { return nil }
    
    let errorsCode = errors.map(renderErrorCode).joined(separator: "\n    ")
    let errorsMessages = errors.map(renderError).joined(separator: "\n    ")
    return """
import Foundation

public enum \(program)Error: String, Error {
    \(errorsCode)

    public var code: String? { self.rawValue }
}

extension \(program)Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
            \(errorsMessages)
        }
    }
}
"""
}
