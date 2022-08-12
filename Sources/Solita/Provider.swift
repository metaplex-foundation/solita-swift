import Foundation
import Solana

class Provider {
    let solana: Solana
    init(solana: Solana, wallet: Wallet) {
        self.solana = solana
    }

    func send(
        tx: TransactionInstruction,
        signers: [Account]?,
        opts: RequestConfiguration?
    ) {

    }

    func sendAll(
        reqs: [SendTxRequest],
        opts: RequestConfiguration?
    ) {

    }

    func simulate(
        tx: TransactionInstruction,
        signers: [Account]?,
        opts: RequestConfiguration?
    ) {

    }
}

protocol Wallet {
    func signTransaction(tx: TransactionInstruction) -> TransactionInstruction
    func signAllTransactions(txs: [TransactionInstruction]) -> [TransactionInstruction]
    var publicKey: PublicKey { get }
}

struct SendTxRequest {
  let tx: TransactionInstruction
  let signers: [Account]
}
