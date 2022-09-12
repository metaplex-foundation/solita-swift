/**
 * This code was GENERATED using the solita package.
 * Please DO NOT EDIT THIS FILE, instead rerun solita to update it or write a wrapper to add functionality.
 *
 * See: https://github.com/metaplex-foundation/solita-swift
 */
import Foundation
import Solana
import Beet

/**
 * @category Instructions
 * @category PrintPurchaseReceipt
 * @category generated
 */
public struct PrintPurchaseReceiptInstructionArgs{
    let instructionDiscriminator: [UInt8] /* size: 8 */
    let purchaseReceiptBump: UInt8
}
/**
 * @category Instructions
 * @category PrintPurchaseReceipt
 * @category generated
 */
public let printPurchaseReceiptStruct = FixableBeetArgsStruct<PrintPurchaseReceiptInstructionArgs>(
    fields: [
        ("instructionDiscriminator", Beet.fixedBeet(.init(value: .collection(UniformFixedSizeArray<UInt8>(element: .init(value: .scalar(u8())), len: 8))))),
        ("purchaseReceiptBump", Beet.fixedBeet(.init(value: .scalar(u8()))))
    ],
    description: "PrintPurchaseReceiptInstructionArgs"
)
/**
* Accounts required by the _printPurchaseReceipt_ instruction
*
* @property [_writable_] purchaseReceipt  
* @property [_writable_] listingReceipt  
* @property [_writable_] bidReceipt  
* @property [_writable_, **signer**] bookkeeper  
* @property [] instruction   
* @category Instructions
* @category PrintPurchaseReceipt
* @category generated
*/
public struct PrintPurchaseReceiptInstructionAccounts {
        let purchaseReceipt: PublicKey
        let listingReceipt: PublicKey
        let bidReceipt: PublicKey
        let bookkeeper: PublicKey
        let systemProgram: PublicKey?
        let rent: PublicKey?
        let instruction: PublicKey
}

public let printPurchaseReceiptInstructionDiscriminator = [103, 108, 111, 98, 97, 108, 58, 112] as [UInt8]

/**
* Creates a _PrintPurchaseReceipt_ instruction.
*
* @param accounts that will be accessed while the instruction is processed
  * @param args to provide as instruction data to the program
 * 
* @category Instructions
* @category PrintPurchaseReceipt
* @category generated
*/
public func createPrintPurchaseReceiptInstruction(accounts: PrintPurchaseReceiptInstructionAccounts, 
args: PrintPurchaseReceiptInstructionArgs, programId: PublicKey=PublicKey(string: "hausS13jsjafwWwGqZTUQRmWyvyxn9EQpqMwV1PBBmk")!) -> TransactionInstruction {

    let data = printPurchaseReceiptStruct.serialize(
            instance: ["instructionDiscriminator": printPurchaseReceiptInstructionDiscriminator,
"purchaseReceiptBump": args.purchaseReceiptBump])

    let keys: [Account.Meta] = [
        Account.Meta(
            publicKey: accounts.purchaseReceipt,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.listingReceipt,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.bidReceipt,
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