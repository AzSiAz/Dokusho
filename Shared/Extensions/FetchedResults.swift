//
//  FetchedResults.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/07/2021.
//

import Foundation
import SwiftUI

extension FetchedResults where Element == Manga {
    func getFiltered(filter: MangaCollection.Filter) -> [Element] {
        let sort = SortDescriptor(\Manga.lastChapterUpdate, order: .reverse)
        
        switch filter {
            case .all:
                return self.sorted(using: sort)
            case .read:
                return self
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }
                        
                        return chapters.allSatisfy { !($0.status == .unread) }
                    }
                    .sorted(using: sort)
            case .unread:
                return self
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }
                        return chapters.contains { $0.status == .unread }
                    }
                    .sorted(using: sort)
        }
    }
}
