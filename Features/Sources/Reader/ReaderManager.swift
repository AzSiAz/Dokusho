//
//  ReaderManager.swift
//  Dokusho
//
//  Created by Stef on 20/04/2022.
//

import Foundation
import DataKit
import SwiftUI

@Observable
public class ReaderManager {
    public struct SelectedChapter: Identifiable {
        public var chapter: MangaChapterDB
        public var manga: MangaDB
        public var scraper: ScraperDB
        public var chapters: [MangaChapterDB]
        
        public var id: String { chapter.id }
    }
    
    public init() {}
    
    public var selectedChapter: SelectedChapter?

    public func selectChapter(chapter: MangaChapterDB, manga: MangaDB, scraper: ScraperDB, chapters: [MangaChapterDB]) {
        self.selectedChapter = .init(chapter: chapter, manga: manga, scraper: scraper, chapters: chapters)
    }
    
    public func dismiss() {
        withAnimation {
            self.selectedChapter = nil
        }
    }
}
