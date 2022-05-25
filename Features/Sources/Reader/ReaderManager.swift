//
//  ReaderManager.swift
//  Dokusho
//
//  Created by Stef on 20/04/2022.
//

import Foundation
import DataKit
import SwiftUI

public class ReaderManager: ObservableObject {
    public struct SelectedChapter: Identifiable {
        public var chapter: MangaChapter
        public var manga: Manga
        public var scraper: Scraper
        public var chapters: [MangaChapter]
        
        public var id: String { chapter.id }
    }
    
    public init() {}
    
    private var database = AppDatabase.shared.database
    
    @Published public var selectedChapter: SelectedChapter?

    public func selectChapter(chapter: MangaChapter, manga: Manga, scraper: Scraper, chapters: [MangaChapter]) {
        self.selectedChapter = .init(chapter: chapter, manga: manga, scraper: scraper, chapters: chapters)
    }
    
    public func dismiss() {
        withAnimation {
            self.selectedChapter = nil
        }
    }
}
