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
        public var chapter: Chapter
        public var manga: Manga
        public var scraper: Scraper
        public var chapters: [Chapter]
        
        public var id: String? { self.chapter.chapterId }
    }
    
    public init() {}
    
    public var selectedChapter: SelectedChapter?

    public func selectChapter(chapter: Chapter, manga: Manga, scraper: Scraper, chapters: [Chapter]) {
        self.selectedChapter = .init(chapter: chapter, manga: manga, scraper: scraper, chapters: chapters)
    }
    
    public func dismiss() {
        withAnimation {
            self.selectedChapter = nil
        }
    }
}
