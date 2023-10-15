import Foundation

extension Array where Element == SerieChapter {
    func next(index: Index) -> Element? {
        let newIdx = index.advanced(by: 1)
        print(newIdx)
        guard newIdx <= index else { return nil }
        return self[newIdx]
    }

    func prev(index: Index) -> Element? {
        let newIdx = index.advanced(by: -1)
        print(newIdx)
        guard newIdx <= endIndex else { return nil }
        return self[newIdx]
    }
}
