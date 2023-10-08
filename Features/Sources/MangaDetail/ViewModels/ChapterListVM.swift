//
//  ChapterListVM.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import Foundation
import SwiftUI
import DataKit

@Observable
public class ChapterListVM {
    @ObservationIgnored
    var manga: MangaDB
    @ObservationIgnored
    var scraper: ScraperDB
    
    var error: Error?
    var selectedChapter: MangaChapterDB?

    public init(manga: MangaDB, scraper: ScraperDB) {
        self.manga = manga
        self.scraper = scraper
    }

    func changeChapterStatus(for chapter: MangaChapterDB, status: ChapterStatus) {
//        do {
//            try database.write { db in
//                try MangaChapterDB.markChapterAs(newStatus: status, db: db, chapterId: chapter.id)
//            }
//        } catch(let err) {
//            print(err)
//        }
    }

    func changePreviousChapterStatus(for chapter: MangaChapterDB, status: ChapterStatus, in chapters: [MangaChapterDB]) {
//        do {
//            try database.write { db in
//                try chapters
//                    .filter { status == .unread ? !$0.isUnread : $0.isUnread }
//                    .filter { chapter.position < $0.position }
//                    .forEach { try MangaChapterDB.markChapterAs(newStatus: status, db: db, chapterId: $0.id) }
//            }
//        } catch(let err) {
//            print(err)
//        }
    }

    func hasPreviousUnreadChapter(for chapter: MangaChapterDB, chapters: [MangaChapterDB]) -> Bool {
        return chapters
            .filter { chapter.position < $0.position }
            .contains { $0.isUnread }
    }

    func nextUnreadChapter(chapters: [MangaChapterDB]) -> MangaChapterDB? {
        return chapters
            .sorted { $0.position > $1.position }
            .first { $0.isUnread }
    }
}
