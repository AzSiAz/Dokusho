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
    var manga: Manga
    @ObservationIgnored
    var scraper: Scraper
    
    var error: Error?
    var selectedChapter: Chapter?

    public init(manga: Manga, scraper: Scraper) {
        self.manga = manga
        self.scraper = scraper
    }

    func changeChapterStatus(for chapter: Chapter, status: Chapter.Status) {
//        do {
//            try database.write { db in
//                try MangaChapterDB.markChapterAs(newStatus: status, db: db, chapterId: chapter.id)
//            }
//        } catch(let err) {
//            print(err)
//        }
    }

    func changePreviousChapterStatus(for chapter: Chapter, status: Chapter.Status, in chapters: [Chapter]) {
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

    func hasPreviousUnreadChapter(for chapter: Chapter, chapters: [Chapter]) -> Bool {
//        return chapters
//            .filter { chapter.position < $0.position }
//            .contains { $0.isUnread }

        return false
    }

    func nextUnreadChapter(chapters: [Chapter]) -> Chapter? {
//        return chapters
//            .sorted { $0.position > $1.position }
//            .first { $0.isUnread }
        
        return nil
    }
}
