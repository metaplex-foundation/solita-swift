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
 * @category PrintListingReceipt
 * @category generated
 */
public struct PrintListingReceiptInstructionArgs{
    let instructionDiscriminator: [UInt8] /* size: 8 */
    let receiptBump: UInt8
}
/**
 * @category Instructions
 * @category PrintListingReceipt
 * @category generated
 */
public let printListingReceiptStruct = FixableBeetArgsStruct<PrintListingReceiptInstructionArgs>(
    fields: [
        ("instructionDiscriminator", Beet.fixedBeet(.init(value: .collection(UniformFixedSizeArray<UInt8>(element: .init(value: .scalar(u8())), len: 8))))),
        ("receiptBump", Beet.fixedBeet(.init(value: .scalar(u8()))))
    ],
    description: "PrintListingReceiptInstructionArgs"
)
/**
* Accounts required by the _printListingReceipt_ instruction
*
* @property [_writable_] receipt  
* @property [_writable_, **signer**] bookkeeper  
* @property [] instruction   
* @category Instructions
* @category PrintListingReceipt
* @category generated
*/
public struct PrintListingReceiptInstructionAccounts {
        let receipt: PublicKey
        let bookkeeper: PublicKey
        let systemProgram: PublicKey?
        let rent: PublicKey?
        let instruction: PublicKey
}

public let printListingReceiptInstructionDiscriminator = [103, 108, 111, 98, 97, 108, 58, 112] as [UInt8]

/**
* Creates a _PrintListingReceipt_ instruction.
*
* @param accounts that will be accessed while the instruction is processed
  * @param args to provide as instruction data to the program
 * 
* @category Instructions
* @category PrintListingReceipt
* @category generated
*/
public func createPrintListingReceiptInstruction(accounts: PrintListingReceiptInstructionAccounts, 
args: PrintListingReceiptInstructionArgs, programId: PublicKey=PublicKey(string: "hausS13jsjafwWwGqZTUQRmWyvyxn9EQpqMwV1PBBmk")!) -> TransactionInstruction {

    let data = printListingReceiptStruct.serialize(
            instance: ["instructionDiscriminator": printListingReceiptInstructionDiscriminator,
"receiptBump": args.receiptBump])

    let keys: [Account.Meta] = [
        Account.Meta(
            publicKey: accounts.receipt,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.bookkeeper,
            isSigner: true,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.systemProgram ?? PublicKey.systemProgramId,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.rent ?? PublicKey.sysvarRent,
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