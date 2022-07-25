//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 7/21/22.
//

import Foundation

protocol BeetReadWrite {
    
    associatedtype T
  /**
   * Writes the value of type {@link T} to the provided buffer.
   *
   * @param buf the buffer to write the serialized value to
   * @param offset at which to start writing into the buffer
   * @param value to write
   */
    func write(buf: Data, offset: UInt, value: Any)
  /**
   * Reads the data in the provided buffer and deserializes it into a value of
   * type {@link T}.
   *
   * @param buf containing the data to deserialize
   * @param offset at which to start reading from the buffer
   * @returns deserialized instance of type {@link T}.
   */
    func read(buf: Data, offset: UInt) -> T

  /**
   * Number of bytes that are used to store the value in a {@link Buffer}
   */
    var byteSize: UInt { get set }
}


protocol ElementCollectionBeet {
  /**
   * For arrays and strings this indicates the byte size of each element.
   */
    var elementByteSize: UInt { get set }

  /**
   * For arrays and strings this indicates the amount of elements/chars.
   */
    var length: UInt { get set }

  /**
   * For arrays and strings this indicates the byte size of the number that
   * indicates its length.
   *
   * Thus the size of each element for arrays is `(this.byteSize - lenPrefixSize) / elementCount`
   */
    var lenPrefixByteSize: UInt { get set }
}
