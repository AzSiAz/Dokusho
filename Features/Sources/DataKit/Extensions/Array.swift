//
//  File.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import Foundation

extension Array where Element == MangaChapterDB {
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
