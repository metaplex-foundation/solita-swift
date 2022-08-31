/**
 * This code was GENERATED using the solita package.
 * Please DO NOT EDIT THIS FILE, instead rerun solita to update it or write a wrapper to add functionality.
 *
 * See: https://github.com/metaplex-foundation/solita-swift
 */
import Foundation
import Beet
import Solana
import BeetSolana

/**
 * @category Instructions
 * @category SetOwnersAndChangeThreshold
 * @category generated
 */
public struct SetOwnersAndChangeThresholdInstructionArgs{
    let instructionDiscriminator: [UInt8] /* size: 8 */
    let owners: [PublicKey]
    let threshold: UInt64
}
/**
 * @category Instructions
 * @category SetOwnersAndChangeThreshold
 * @category generated
 */
public let setOwnersAndChangeThresholdStruct = FixableBeetArgsStruct<SetOwnersAndChangeThresholdInstructionArgs>(
    fields: [
        ("instructionDiscriminator", Beet.fixedBeet(.init(value: .collection(UniformFixedSizeArray<UInt8>(element: .init(value: .scalar(u8())), len: 8))))),
        ("owners", Beet.fixableBeat(array(element: Beet.fixedBeet(.init(value: .scalar(BeetPublicKey())))))),
    ("threshold", Beet.fixedBeet(.init(value: .scalar(u64()))))
    ],
    description: "SetOwnersAndChangeThresholdInstructionArgs"
)
/**
* Accounts required by the _setOwnersAndChangeThreshold_ instruction
*
* @property [_writable_] multisig  
* @property [**signer**] multisigSigner   
* @category Instructions
* @category SetOwnersAndChangeThreshold
* @category generated
*/
public struct SetOwnersAndChangeThresholdInstructionAccounts {
        let multisig: PublicKey
        let multisigSigner: PublicKey
}

public let setOwnersAndChangeThresholdInstructionDiscriminator = [103, 108, 111, 98, 97, 108, 58, 115] as [UInt8]

/**
* Creates a _SetOwnersAndChangeThreshold_ instruction.
*
* @param accounts that will be accessed while the instruction is processed
  * @param args to provide as instruction data to the program
 * 
* @category Instructions
* @category SetOwnersAndChangeThreshold
* @category generated
*/
public func createSetOwnersAndChangeThresholdInstruction(accounts: SetOwnersAndChangeThresholdInstructionAccounts, 
args: SetOwnersAndChangeThresholdInstructionArgs, programId: PublicKey=PublicKey(string: "")!) -> TransactionInstruction {

    let data = setOwnersAndChangeThresholdStruct.serialize(
            instance: ["instructionDiscriminator": setOwnersAndChangeThresholdInstructionDiscriminator,
"owners": args.owners,
  "threshold": args.threshold],  byteSize: nil
    )

    let keys: [Account.Meta] = [
        Account.Meta(
            publicKey: accounts.multisig,
            isSigner: false,
            isWritable: true
        ),
        Account.Meta(
            publicKey: accounts.multisigSigner,
            isSigner: true,
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