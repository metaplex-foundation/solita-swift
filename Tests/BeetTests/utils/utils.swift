import Foundation
import XCTest
@testable import Beet

func checkFixedSerialize<T>(
  fixedBeet: FixedSizeBeet,
  value: T,
  data: Data,
  description: String
) {
    var buf = Data(count: Int(fixedBeet.byteSize))
    fixedBeet.write(buf: &buf, offset: 0, value: value)
    XCTAssertEqual(data, buf)
}

func checkFixedDeserialize<T: Equatable>(
  fixedBeet: FixedSizeBeet,
  value: T,
  data: Data,
  description: String
) {
    let actual: T = fixedBeet.read(buf: data, offset: 0)
    XCTAssertEqual(actual, value)
}

func checkFixedSerialization<T: Equatable>(
  fixedBeet: FixedSizeBeet,
  value: T,
  data: Data,
  description: String
) {
    checkFixedSerialize(fixedBeet: fixedBeet, value: value, data: data, description: description)
    checkFixedDeserialize(fixedBeet: fixedBeet, value: value, data: data, description: description)
}

func checkFixableFromDataSerialization<T: Equatable>(
  fixabledBeet: FixableBeet,
  value: T,
  data: Data,
  description: String
) {
    let fixedBeet = fixabledBeet.toFixedFromData(buf: data, offset: 0)
    checkFixedSerialize(fixedBeet: fixedBeet, value: value, data: data, description: description)
    checkFixedDeserialize(fixedBeet: fixedBeet, value: value, data: data, description: description)
}

func checkFixableFromValueSerialization<T: Equatable>(
  fixabledBeet: FixableBeet,
  value: T,
  data: Data,
  description: String
) {
    let fixedBeet = fixabledBeet.toFixedFromValue(val: value)
    checkFixedSerialize(fixedBeet: fixedBeet, value: value, data: data, description: description)
    checkFixedDeserialize(fixedBeet: fixedBeet, value: value, data: data, description: description)
}
