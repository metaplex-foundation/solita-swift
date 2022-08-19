import Foundation
import Solana

public struct ResolvedKnownPubkey {
    let exp: String
    let pack: PubkeysPackage
    let packExportName: PubkeysPackageExportName
}

public func resolveKnownPubkey(id: String) -> ResolvedKnownPubkey? {
    let item = knownPubkeysMap[id]
    guard let item = item else { return nil }

    let packExportName = pubkeysPackageExportName(pack: item.pack)
    return ResolvedKnownPubkey(exp: item.exp, pack: item.pack, packExportName: packExportName)
}

func pubkeysPackageExportName(
  pack: PubkeysPackage
) -> PubkeysPackageExportName {
  switch (pack) {
  case .SOLANA_SPL_TOKEN_PACKAGE:
      return .SOLANA_SPL_TOKEN_EXPORT_NAME
  case .SOLANA_WEB3_PACKAGE:
      return .SOLANA_WEB3_EXPORT_NAME
  case .PROGRAM_ID_PACKAGE:
      return .PROGRAM_ID_EXPORT_NAME
    default: fatalError("Unreachable Error")
  }
}

public enum PubkeysPackage {
  case SOLANA_WEB3_PACKAGE
  case SOLANA_SPL_TOKEN_PACKAGE
  case PROGRAM_ID_PACKAGE
}
public enum PubkeysPackageExportName {
    case SOLANA_WEB3_EXPORT_NAME
    case SOLANA_SPL_TOKEN_EXPORT_NAME
    case PROGRAM_ID_EXPORT_NAME
}

let knownPubkeysMap: Dictionary<String, (exp: String, pack: PubkeysPackage)> = [
    "tokenProgram": (exp: "TOKEN_PROGRAM_ID", pack: .SOLANA_SPL_TOKEN_PACKAGE ),
    "ataProgram": (exp: "ASSOCIATED_TOKEN_PROGRAM_ID", pack: .SOLANA_SPL_TOKEN_PACKAGE ),
    "systemProgram": (exp: "SystemProgram.programId", pack: .SOLANA_WEB3_PACKAGE ),
    "rent": (exp: "SYSVAR_RENT_PUBKEY", pack: .SOLANA_WEB3_PACKAGE ),
    "programId": (exp: PROGRAM_ID_EXPORT_NAME, pack: .PROGRAM_ID_PACKAGE ),
  ]

public func isKnownPubkey(id: String) -> Bool {
    return knownPubkeysMap[id] != nil
}
public func isProgramIdPubkey(id: String) -> Bool {
    return id == "programId"
}

public func isProgramIdKnownPubkey(knownPubkey: ResolvedKnownPubkey) -> Bool{
  return
    knownPubkey.exp == PROGRAM_ID_EXPORT_NAME && knownPubkey.pack == .PROGRAM_ID_PACKAGE
  
}
public func renderKnownPubkeyAccess(
  knownPubkey: ResolvedKnownPubkey,
  programIdPubkey: String
) -> String{
    if isProgramIdKnownPubkey(knownPubkey: knownPubkey) {
        return programIdPubkey
    }
    let exp = knownPubkey.exp
    let packExportName = knownPubkey.packExportName
  return "\(packExportName).\(exp)"
}
