import Foundation

protocol BytesEncodable {
    var bytes: [UInt8] { get }
}

extension UInt8: BytesEncodable {
    var bytes: [UInt8] { [self] }
}

extension UInt32: BytesEncodable {
    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}

extension UInt64: BytesEncodable {
    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }

    public func convertToBalance(decimals: Int?) -> Double {
        guard let decimals = decimals else {return 0}
        return convertToBalance(decimals: UInt8(decimals))
    }

    public func convertToBalance(decimals: UInt8?) -> Double {
        guard let decimals = decimals else {return 0}
        return Double(self) * pow(10, -Double(decimals))
    }
}

extension Data: BytesEncodable {
    public var bytes: [UInt8] {
      Array(self)
    }
}

extension Bool: BytesEncodable {
    var bytes: [UInt8] {self ? [UInt8(1)]: [UInt8(0)]}
}

extension Array: BytesEncodable where Element == BytesEncodable {
    var bytes: [UInt8] {reduce([], {$0 + $1.bytes})}
}

extension RawRepresentable where RawValue == UInt32 {
    var bytes: [UInt8] { rawValue.bytes}
}

extension RawRepresentable where RawValue == UInt8 {
    var bytes: [UInt8] {rawValue.bytes}
}
