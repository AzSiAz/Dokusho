//
//  ChapterListVM.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import Foundation
import CoreData
import SwiftUI

class ChapterListVM: ObservableObject {
    private let database = AppDatabase.shared.database

    var manga: Manga
    var scraper: Scraper
    
    @Published var error: Error?
    @Published var selectedChapter: MangaChapter?

    init(manga: Manga, scraper: Scraper) {
        self.manga = manga
        self.scraper = scraper
    }

    func changeChapterStatus(for chapter: MangaChapter, status: ChapterStatus) {
        do {
            try database.write { db in
                try MangaChapter.markChapterAs(newStatus: status, db: db, chapterId: chapter.id)
            }
        } catch(let err) {
            print(err)
        }
    }

    func changePreviousChapterStatus(for chapter: MangaChapter, status: ChapterStatus, in chapters: [MangaChapter]) {
        do {
            try database.write { db in
                try chapters
                    .filter { status == .unread ? !$0.isUnread : $0.isUnread }
                    .filter { chapter.position < $0.position }
                    .forEach { try MangaChapter.markChapterAs(newStatus: status, db: db, chapterId: $0.id) }
            }
        } catch(let err) {
            print(err)
        }
    }

    func hasPreviousUnreadChapter(for chapter: MangaChapter, chapters: [MangaChapter]) -> Bool {
        return chapters
            .filter { chapter.position < $0.position }
            .contains { $0.isUnread }
    }

    func nextUnreadChapter(chapters: [MangaChapter]) -> MangaChapter? {
        return chapters
            .sorted { $0.position > $1.position }
            .first { $0.isUnread }
    }
}
