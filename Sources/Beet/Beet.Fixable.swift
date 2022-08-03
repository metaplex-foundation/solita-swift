import Foundation

func fixBeetFromData(beet: Beet, buf: Data, offset: Int) -> FixedSizeBeet {
    switch beet {
    case .fixedBeet(let fixedSizeBeet):
        return fixedSizeBeet
    case .fixableBeat(let fixableBeet):
        return fixableBeet.toFixedFromData(buf: buf, offset: offset)
    }
}

func fixBeetFromValue<V>(beet: Beet, val: V) -> FixedSizeBeet {
    switch beet {
    case .fixedBeet(let fixedSizeBeet):
        return fixedSizeBeet
    case .fixableBeat(let fixableBeet):
        return fixableBeet.toFixedFromValue(val: val)
    }
}
