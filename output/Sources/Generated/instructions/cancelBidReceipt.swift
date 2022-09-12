/**
 * This code was GENERATED using the solita package.
 * Please DO NOT EDIT THIS FILE, instead rerun solita to update it or write a wrapper to add functionality.
 *
 * See: https://github.com/metaplex-foundation/solita-swift
 */
import Foundation
import Beet
import Solana

/**
 * @category Instructions
 * @category CancelBidReceipt
 * @category generated
 */
public struct CancelBidReceiptInstructionArgs{
    let instructionDiscriminator: [UInt8] /* size: 8 */
    
}
/**
 * @category Instructions
 * @category CancelBidReceipt
 * @category generated
 */
public let cancelBidReceiptStruct = FixableBeetArgsStruct<CancelBidReceiptInstructionArgs>(
    fields: [
        ("instructionDiscriminator", Beet.fixedBeet(.init(value: .collection(UniformFixedSizeArray<UInt8>(element: .init(value: .scalar(u8())), len: 8))))),
        
    ],
    description: "CancelBidReceiptInstructionArgs"
)
/**
* Accounts required by the _cancelBidReceipt_ instruction
*
* @property [_writable_] receipt  
* @property [] instruction   
* @category Instructions
* @category CancelBidReceipt
* @category generated
*/
public struct CancelBidReceiptInstructionAccounts {
        let receipt: PublicKey
        let systemProgram: PublicKey?
        let instruction: PublicKey
}

public let cancelBidReceiptInstructionDiscriminator = [103, 108, 111, 98, 97, 108, 58, 99] as [UInt8]

/**
* Creates a _CancelBidReceipt_ instruction.
*
* @param accounts that will be accessed while the instruction is processed
* @category Instructions
* @category CancelBidReceipt
* @category generated
*/
public func createCancelBidReceiptInstruction(accounts: CancelBidReceiptInstructionAccounts, 
programId: PublicKey=PublicKey(string: "hausS13jsjafwWwGqZTUQRmWyvyxn9EQpqMwV1PBBmk")!) -> TransactionInstruction {

    let data = cancelBidReceiptStruct.serialize(
            instance: ["instructionDiscriminator": cancelBidReceiptInstructionDiscriminator ])

    let keys: [Account.Meta] = [
        Account.Meta(
            publicKey: accounts.receipt,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.systemProgram ?? PublicKey.systemProgramId,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.instruction,
            isSigner: false,
            isWritable: false
        )
    ]

    let ix = TransactionInstruction(
                keys: keys,
                programId: programId,
                data: data.0.bytes
            )
    return ix
}