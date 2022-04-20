//
//  ReaderManager.swift
//  Dokusho
//
//  Created by Stef on 20/04/2022.
//

import Foundation

class ReaderManager: ObservableObject {
    struct SelectedChapter: Identifiable {
        var chapter: MangaChapter
        var manga: Manga
        var scraper: Scraper
        
        var id: String { chapter.id }
    }
    
    var database = AppDatabase.shared.database
    
    @Published var selectedChapter: SelectedChapter?

    func selectChapter(chapter: MangaChapter, manga: Manga, scraper: Scraper) {
        self.selectedChapter = .init(chapter: chapter, manga: manga, scraper: scraper)
    }
    
    func dismiss() {
        self.selectedChapter = nil
    }
}
