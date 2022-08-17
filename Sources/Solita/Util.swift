import Foundation

func withoutTsExtension(p: String) -> String {
    return p.replacingOccurrences(of: ".swift", with: "")
}
