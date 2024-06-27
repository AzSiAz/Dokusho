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
        public var chapter: SerieChapter
        public var serie: Serie
        public var scraper: Scraper
        public var chapters: [SerieChapter]
        
        public var id: String? { self.chapter.internalID }
    }
    
    public init() {}
    
    public var selectedChapter: SelectedChapter?

    public func selectChapter(chapter: SerieChapter, serie: Serie, scraper: Scraper, chapters: [SerieChapter]) {
        self.selectedChapter = .init(chapter: chapter, serie: serie, scraper: scraper, chapters: chapters)
    }
    
    public func dismiss() {
        withAnimation {
            self.selectedChapter = nil
        }
    }
}
