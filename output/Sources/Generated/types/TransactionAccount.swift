import BeetSolana
import Beet
import Solana

public struct TransactionAccount {
    let pubkey: PublicKey
    let isSigner: Bool
    let isWritable: Bool
}

/**
 * @category userTypes
 * @category generated
 */
public let transactionAccountBeet = BeetArgsStruct(fields: [
    ("pubkey", (.init(value: .scalar(BeetPublicKey())))),
    ("isSigner", (.init(value: .scalar(bool())))),
    ("isWritable", (.init(value: .scalar(bool()))))
], description: "TransactionAccount")