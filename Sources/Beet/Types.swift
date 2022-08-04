//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 7/21/22.
//

import Foundation
import Solana


/**
 * Base Beet type.
 * @category beet
 */
protocol BeetBase {
  /**
   * Describes the type of data that is de/serialized and serves for debugging
   * and diagnostics only.
   */
    var description: String { get }
}

protocol BeetReadWrite {
    
    /**
   * Writes the value of type {@link T} to the provided buffer.
   *
   * @param buf the buffer to write the serialized value to
   * @param offset at which to start writing into the buffer
   * @param value to write
   */
    func write<T>(buf: inout Data, offset: Int, value: T)
  /**
   * Reads the data in the provided buffer and deserializes it into a value of
   * type {@link T}.
   *
   * @param buf containing the data to deserialize
   * @param offset at which to start reading from the buffer
   * @returns deserialized instance of type {@link T}.
   */
    func read<T>(buf: Data, offset: Int) -> T

  /**
   * Number of bytes that are used to store the value in a {@link Buffer}
   */
    var byteSize: UInt { get }
}


protocol ElementCollectionBeet {
  /**
   * For arrays and strings this indicates the byte size of each element.
   */
    var elementByteSize: UInt { get set }

  /**
   * For arrays and strings this indicates the amount of elements/chars.
   */
    var length: UInt32 { get set }

  /**
   * For arrays and strings this indicates the byte size of the number that
   * indicates its length.
   *
   * Thus the size of each element for arrays is `(this.byteSize - lenPrefixSize) / elementCount`
   */
    var lenPrefixByteSize: UInt { get set }
}

/**
 * Scalar Beet
 * @category beet
 */
protocol ScalarFixedSizeBeet: BeetBase & BeetReadWrite {}


/**
 * Beet for Collections
 * @category beet
 */
protocol ElementCollectionFixedSizeBeet: BeetBase & BeetReadWrite & ElementCollectionBeet {}

/**
 * Template for De/Serializer which is of fixed size, meaning its Buffer size
 * when serialized doesn't change depending on the data it contains.
 *
 * @template T is the data type which is being de/serialized
 * @template V is the value type passed to the write which includes all
 * properties needed to produce {@link T}, defaults to `Partial<T>`
 *
 * @category beet
 */

enum FixedSizeBeetType {
    case scalar(ScalarFixedSizeBeet)
    case collection (ElementCollectionFixedSizeBeet)
}

class FixedSizeBeet {
    let value: FixedSizeBeetType
    init(value: FixedSizeBeetType){
        self.value = value
    }
}

/**
 * Template for De/Serializer which has a dynamic size, meaning its Buffer size
 * when serialized changes depending on the data it contains.
 *
 * It is _fixable_ in the sense that a {@link FixedSizeBeet} can be derived
 * from it by providing either the value or serialized data for the particular
 * instance.
 *
 * @template T is the data type which is being de/serialized
 * @template V is the value type passed to the write which includes all
 * properties needed to produce {@link T}, defaults to `Partial<T>`
 *
 * @category beet
 */
protocol FixableBeet: BeetBase {
  /**
   * Provides a fixed size version of `this` by walking the provided data in
   * order to discover the sizes of the root beet and all nested beets.
   *
   * @param buf the Buffer containing the data for which to adapt this beet to
   * fixed size
   * @param offset the offset at which the data starts
   *
   */
    func toFixedFromData(buf: Data, offset: Int) -> FixedSizeBeet

  /**
   * Provides a fixed size version of `this` by walking the provided value in
   * order to discover the sizes of the root beet and all nested beets.
   *
   * @param val the instance for which to adapt this beet to fixed size
   */
    func toFixedFromValue(val: Any) -> FixedSizeBeet
}


/**
 * @category beet
 */
enum Beet {
    case fixedBeet(FixedSizeBeet)
    case fixableBeat(FixableBeet)
}

/**
 * Specifies a field that is part of the type {@link T} along with its De/Serializer.
 *
 * @template T the type of which the field is a member
 *
 * @category beet
 */
typealias FixedBeetField = (type: AnyHashable, beet: FixedSizeBeet)


/**
 * Specifies a field that is part of the type {@link T} along with its De/Serializer.
 *
 * @template T the type of which the field is a member
 *
 * @category beet
 */
typealias BeetField = (type: AnyHashable, beet: Beet)

/**
 * Represents a number that can be larger than the builtin Integer type.
 * It is backed by {@link https://github.com/indutny/bn.js | BN} for large numbers.
 *
 * @category beet
 */
typealias bignum = Bignum

/**
 * @private
 * @category beet
 */
let BEET_TYPE_ARG_LEN = "len"

/**
 * @private
 * @category beet
 */
let BEET_TYPE_ARG_INNER = "Beet<{innner}>"

enum BeetTypeArg {
    case len
    case inner
    
    func value() -> String {
        switch self {
        case .len: return BEET_TYPE_ARG_LEN
        case .inner: return BEET_TYPE_ARG_INNER
        }
    }
}

/**
 * Defines a type supported by beet.
 *
 * @property beet is the Beet reader/writer to use for serialization
 *  - this could also be a function that produces it (when arg is set)
 * @property isFixable if `true` the size of structs of this type depends on
 * the value/data they hold and needs to be _fixed_ with a value or data
 * NOTE: that if this is `false`, the struct is considered _fixed_ size which
 * means it has the same size no matter what value it holds
 * @property sourcPack the package where the definition is exported,
 * i.e. beet or beet-solana
 * @property ts is the TypeScript type representing the deserialized type
 * @property arg specifies the type of arg to provide to create the Beet type
 *   - len: for fixed size arrays and strings
 *   - beet.Beet<T>: an inner Beet type 'T' for composite types like Option<Inner>
 * @property pack specifies which package is exporting the `ts` type if it is
 * not built in
 *
 * @category TypeDefinition
 */
struct SupportedTypeDefinition {
    let beet: String
    let isFixable: Bool
    let sourcePack: String
    let swift: String
    let arg: BeetTypeArg
    let letpack: String?
}

typealias Enum = CaseIterable

// -----------------
// Guards
// -----------------
/**
 * @private
 */
func isFixedSizeBeet(x: Beet) -> Bool {
    switch x {
    case .fixedBeet:
        return true
    case .fixableBeat:
        return false
    }
}

/**
 * @private
 */
func assertFixedSizeBeet(x: Beet, description: String?) {
    if let description = description {
        assert(isFixedSizeBeet(x: x), description)

    }
    assert(isFixedSizeBeet(x: x), "\(x) should have been a fixed beet")
}

/**
 * @private
 */
func isFixableBeet(x: Beet) -> Bool {
    switch x {
    case .fixedBeet:
        return false
    case .fixableBeat:
        return true
    }
}
