//
//  Array.swift
//  Hanako
//
//  Created by Stephan Deumier on 30/12/2020.
//

import Foundation
import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    func get(index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}

extension Array where Element == MangaChapter {
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

extension Sequence {
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted { a, b in
            comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }
}
