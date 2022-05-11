//
//  ReaderManager.swift
//  Dokusho
//
//  Created by Stef on 20/04/2022.
//

import Foundation
import DataKit

class ReaderManager: ObservableObject {
    struct SelectedChapter: Identifiable {
        var chapter: MangaChapter
        var manga: Manga
        var scraper: Scraper
        var chapters: [MangaChapter]
        
        var id: String { chapter.id }
    }
    
    var database = AppDatabase.shared.database
    
    @Published var selectedChapter: SelectedChapter?

    func selectChapter(chapter: MangaChapter, manga: Manga, scraper: Scraper, chapters: [MangaChapter]) {
        self.selectedChapter = .init(chapter: chapter, manga: manga, scraper: scraper, chapters: chapters)
    }
    
    func dismiss() {
        self.selectedChapter = nil
    }
}
