/**
 * This code was GENERATED using the solita package.
 * Please DO NOT EDIT THIS FILE, instead rerun solita to update it or write a wrapper to add functionality.
 *
 * See: https://github.com/metaplex-foundation/solita-swift
 */
import Foundation
import BeetSolana
import Solana
import Beet


/**
* Arguments used to create {@link Transaction}
* @category Accounts
* @category generated
*/
protocol TransactionArgs {
    
    var multisig: PublicKey { get }
    var programId: PublicKey { get }
    var accounts: [TransactionAccount] { get }
    var data: Data { get }
    var signers: [Bool] { get }
    var didExecute: Bool { get }
    var ownerSetSeqno: UInt32 { get }
}


/**
 * Holds the data for the {@link Transaction} Account and provides de/serialization
 * functionality for that data
 *
 * @category Accounts
 * @category generated
 */
public struct Transaction: TransactionArgs {
  let multisig: PublicKey
  let programId: PublicKey
  let accounts: [TransactionAccount]
  let data: Data
  let signers: [Bool]
  let didExecute: Bool
  let ownerSetSeqno: UInt32

  /**
   * Creates a {@link Transaction} instance from the provided args.
   */
  static func fromArgs(args: Args) -> Transaction {
    return Transaction(
        multisig: args["multisig"] as! PublicKey,
        programId: args["programId"] as! PublicKey,
        accounts: args["accounts"] as! [TransactionAccount],
        data: args["data"] as! Data,
        signers: args["signers"] as! [Bool],
        didExecute: args["didExecute"] as! Bool,
        ownerSetSeqno: args["ownerSetSeqno"] as! UInt32
    )
  }
  /**
   * Deserializes the {@link Transaction} from the data of the provided {@link web3.AccountInfo}.
   * @returns a tuple of the account data and the offset up to which the buffer was read to obtain it.
   */
  static func fromAccountInfo(
    accountInfo: Data,
    offset:Int=0
  ) -> ( Transaction, Int )  {
    return Transaction.deserialize(buf: accountInfo, offset: offset)
  }
  /**
   * Retrieves the account info from the provided address and deserializes
   * the {@link Transaction} from its data.
   *
   * @throws Error if no account info is found at the address or if deserialization fails
   */
  static func fromAccountAddress(
    connection: Api,
    address: PublicKey,
    onComplete: @escaping (Result<Transaction, Error>) -> Void
  ) {
    connection.getAccountInfo(account: address.base58EncodedString) { result in
        switch result {
            case .success(let pureData):
                if let data = pureData.data?.value {
                    onComplete(.success(Transaction.deserialize(buf: data).0))
                } else {
                    onComplete(.failure(SolanaError.nullValue))
                }
            case .failure(let error):
                onComplete(.failure(error))
        }
    }
  }
  /**
   * Deserializes the {@link Transaction} from the provided data Buffer.
   * @returns a tuple of the account data and the offset up to which the buffer was read to obtain it.
   */
  static func deserialize(
    buf: Data,
    offset: Int = 0
  ) -> ( Transaction, Int ) {
    return transactionBeet.deserialize(buffer: buf, offset: offset)
  }
  /**
   * Serializes the {@link Transaction} into a Buffer.
   * @returns a tuple of the created Buffer and the offset up to which the buffer was written to store it.
   */
  func serialize() -> ( Data, Int ) {
    return transactionBeet.serialize(instance: [
        "multisig" : self.multisig,
        "programId" : self.programId,
        "accounts" : self.accounts,
        "data" : self.data,
        "signers" : self.signers,
        "didExecute" : self.didExecute,
        "ownerSetSeqno" : self.ownerSetSeqno], byteSize: nil)
  }
  /**
* Returns the byteSize of a {@link Buffer} holding the serialized data of
* {@link Transaction} for the provided args.
*
* @param args need to be provided since the byte size for this account
* depends on them
*/
static func byteSize(args: TransactionArgs) -> UInt64 {
    return UInt64(transactionBeet.toFixedFromValue(val: args).byteSize)
}
/**
* Fetches the minimum balance needed to exempt an account holding
* {@link Transaction} data from rent
*
* @param args need to be provided since the byte size for this account
* depends on them
* @param connection used to retrieve the rent exemption information
*/
static func getMinimumBalanceForRentExemption(
    args: TransactionArgs,
    connection: Api,
    commitment: Commitment?,
    onComplete: @escaping(Result<UInt64, Error>) -> Void
) {
    return connection.getMinimumBalanceForRentExemption(dataLength: Transaction.byteSize(args: args), commitment: commitment, onComplete: onComplete)
}
}
  /**
   * @category Accounts
   * @category generated
   */
  public let transactionBeet = FixableBeetStruct<Transaction>(
    fields:[
        
        ("multisig", Beet.fixedBeet(.init(value: .scalar(BeetPublicKey())))),
    ("programId", Beet.fixedBeet(.init(value: .scalar(BeetPublicKey())))),
    ("accounts", Beet.fixableBeat(array(element: .fixedBeet(.init(value: .scalar(transactionAccountBeet)))))),
    ("data", Beet.fixableBeat(Uint8Array())),
    ("signers", Beet.fixableBeat(array(element: Beet.fixedBeet(.init(value: .scalar(bool())))))),
    ("didExecute", Beet.fixedBeet(.init(value: .scalar(bool())))),
    ("ownerSetSeqno", Beet.fixedBeet(.init(value: .scalar(u32()))))
    ],
    construct: Transaction.fromArgs,
    description: "Transaction"
)