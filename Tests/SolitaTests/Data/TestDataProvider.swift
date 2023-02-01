//
//  TestDataProvider.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/24/22.
//

import Foundation
@testable import Solita

struct TestDataProvider {
    static let serumMultisigJson = stubbedResponse("serum_multisig")
    static let auctionHouseJson = stubbedResponse("action_house")
    static let candyMachineJson = stubbedResponse("candy_machine")
    static let fanoutJson = stubbedResponse("fanout")
    static let featDataEnum = stubbedResponse("feat-data-enum")

    static let discriminatorInstruction = InstructionDiscriminator(
        ix: IdlInstruction(name: "createAuctionHouse", accounts: [], args: [], defaultOptionalAccounts: nil, docs: nil),
        fieldName: "createAuctionHouse",
        typeMapper: TypeMapper()
    )
    static let expectedDiscriminatorRenderValue = "[221, 66, 242, 159, 249, 206, 134, 241] as [UInt8]"
    static let expectedDiscriminatorFieldName = "createAuctionHouse"
    static let expectedDiscriminatorRenderType = "[UInt8] /* size: 8 */"

    static let expectedAccountDescriminatorBytes: [UInt8] = [186, 150, 141, 135, 59, 122, 39, 99]

    private static func stubbedResponse(_ filename: String) -> Data {
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let resourceURL = thisDirectory.appendingPathComponent("../Resources/\(filename).json")
        return try! Data(contentsOf: resourceURL)
    }
}
