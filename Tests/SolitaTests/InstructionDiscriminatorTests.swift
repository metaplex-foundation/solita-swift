//
//  InstructionDiscriminatorTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/24/22.
//

import XCTest
@testable import Solita

final class InstructionDiscriminatorTests: XCTestCase {
    func testInstructionDiscriminatorRenderValue() {
        let discriminatorInstruction = TestDataProvider.discriminatorInstruction
        XCTAssertEqual(discriminatorInstruction.renderValue(), TestDataProvider.expectedDiscriminatorRenderValue)
    }

    func testInstructionDiscriminatorField() {
        let discriminatorInstruction = TestDataProvider.discriminatorInstruction
        XCTAssertEqual(discriminatorInstruction.getField().name, TestDataProvider.expectedDiscriminatorFieldName)
    }

    func testInstructionDiscriminatorRenderType() {
        let discriminatorInstruction = TestDataProvider.discriminatorInstruction
        XCTAssertEqual(discriminatorInstruction.renderType(), TestDataProvider.expectedDiscriminatorRenderType)
    }
}
