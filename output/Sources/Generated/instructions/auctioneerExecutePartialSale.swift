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
 * @category AuctioneerExecutePartialSale
 * @category generated
 */
public struct AuctioneerExecutePartialSaleInstructionArgs{
    let instructionDiscriminator: [UInt8] /* size: 8 */
    let escrowPaymentBump: UInt8
    let freeTradeStateBump: UInt8
    let programAsSignerBump: UInt8
    let buyerPrice: UInt64
    let tokenSize: UInt64
    let partialOrderSize: COption<UInt64>
    let partialOrderPrice: COption<UInt64>
}
/**
 * @category Instructions
 * @category AuctioneerExecutePartialSale
 * @category generated
 */
public let auctioneerExecutePartialSaleStruct = FixableBeetArgsStruct<AuctioneerExecutePartialSaleInstructionArgs>(
    fields: [
        ("instructionDiscriminator", Beet.fixedBeet(.init(value: .collection(UniformFixedSizeArray<UInt8>(element: .init(value: .scalar(u8())), len: 8))))),
        ("escrowPaymentBump", Beet.fixedBeet(.init(value: .scalar(u8())))),
        ("freeTradeStateBump", Beet.fixedBeet(.init(value: .scalar(u8())))),
        ("programAsSignerBump", Beet.fixedBeet(.init(value: .scalar(u8())))),
        ("buyerPrice", Beet.fixedBeet(.init(value: .scalar(u64())))),
        ("tokenSize", Beet.fixedBeet(.init(value: .scalar(u64())))),
        ("partialOrderSize", Beet.fixableBeat(coption(inner: Beet.fixedBeet(.init(value: .scalar(u64())))))),
        ("partialOrderPrice", Beet.fixableBeat(coption(inner: Beet.fixedBeet(.init(value: .scalar(u64()))))))
    ],
    description: "AuctioneerExecutePartialSaleInstructionArgs"
)
/**
* Accounts required by the _auctioneerExecutePartialSale_ instruction
*
* @property [_writable_] buyer  
* @property [_writable_] seller  
* @property [_writable_] tokenAccount  
* @property [] tokenMint  
* @property [] metadata  
* @property [] treasuryMint  
* @property [_writable_] escrowPaymentAccount  
* @property [_writable_] sellerPaymentReceiptAccount  
* @property [_writable_] buyerReceiptTokenAccount  
* @property [] authority  
* @property [**signer**] auctioneerAuthority  
* @property [] auctionHouse  
* @property [_writable_] auctionHouseFeeAccount  
* @property [_writable_] auctionHouseTreasury  
* @property [_writable_] buyerTradeState  
* @property [_writable_] sellerTradeState  
* @property [_writable_] freeTradeState  
* @property [] ahAuctioneerPda  
* @property [] programAsSigner   
* @category Instructions
* @category AuctioneerExecutePartialSale
* @category generated
*/
public struct AuctioneerExecutePartialSaleInstructionAccounts {
        let buyer: PublicKey
        let seller: PublicKey
        let tokenAccount: PublicKey
        let tokenMint: PublicKey
        let metadata: PublicKey
        let treasuryMint: PublicKey
        let escrowPaymentAccount: PublicKey
        let sellerPaymentReceiptAccount: PublicKey
        let buyerReceiptTokenAccount: PublicKey
        let authority: PublicKey
        let auctioneerAuthority: PublicKey
        let auctionHouse: PublicKey
        let auctionHouseFeeAccount: PublicKey
        let auctionHouseTreasury: PublicKey
        let buyerTradeState: PublicKey
        let sellerTradeState: PublicKey
        let freeTradeState: PublicKey
        let ahAuctioneerPda: PublicKey
        let tokenProgram: PublicKey?
        let systemProgram: PublicKey?
        let ataProgram: PublicKey?
        let programAsSigner: PublicKey
        let rent: PublicKey?
}

public let auctioneerExecutePartialSaleInstructionDiscriminator = [103, 108, 111, 98, 97, 108, 58, 97] as [UInt8]

/**
* Creates a _AuctioneerExecutePartialSale_ instruction.
*
* @param accounts that will be accessed while the instruction is processed
  * @param args to provide as instruction data to the program
 * 
* @category Instructions
* @category AuctioneerExecutePartialSale
* @category generated
*/
public func createAuctioneerExecutePartialSaleInstruction(accounts: AuctioneerExecutePartialSaleInstructionAccounts, 
args: AuctioneerExecutePartialSaleInstructionArgs, programId: PublicKey=PublicKey(string: "hausS13jsjafwWwGqZTUQRmWyvyxn9EQpqMwV1PBBmk")!) -> TransactionInstruction {

    let data = auctioneerExecutePartialSaleStruct.serialize(
            instance: ["instructionDiscriminator": auctioneerExecutePartialSaleInstructionDiscriminator,
"escrowPaymentBump": args.escrowPaymentBump,
  "freeTradeStateBump": args.freeTradeStateBump,
  "programAsSignerBump": args.programAsSignerBump,
  "buyerPrice": args.buyerPrice,
  "tokenSize": args.tokenSize,
  "partialOrderSize": args.partialOrderSize,
  "partialOrderPrice": args.partialOrderPrice])

    let keys: [Account.Meta] = [
        Account.Meta(
            publicKey: accounts.buyer,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.seller,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.tokenAccount,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.tokenMint,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.metadata,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.treasuryMint,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.escrowPaymentAccount,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.sellerPaymentReceiptAccount,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.buyerReceiptTokenAccount,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.authority,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.auctioneerAuthority,
            isSigner: true,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.auctionHouse,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.auctionHouseFeeAccount,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.auctionHouseTreasury,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.buyerTradeState,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.sellerTradeState,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.freeTradeState,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.ahAuctioneerPda,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.tokenProgram ?? PublicKey.tokenProgramId,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.systemProgram ?? PublicKey.systemProgramId,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.ataProgram ?? PublicKey.splAssociatedTokenAccountProgramId,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.programAsSigner,
            isSigner: false,
            isWritable: false
        ),
        Account.Meta(
            publicKey: accounts.rent ?? PublicKey.sysvarRent,
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