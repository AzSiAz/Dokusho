//
//  ReaderVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import Foundation
import CoreData
import SwiftUI
import OSLog
import MangaScraper
import Nuke

enum GoToChapterDirection {
    case next, previous
}

class ReaderVM: ObservableObject {
    private let database = AppDatabase.shared.database
    
    @Published var chapter: MangaChapter
    @Published var images = [SourceChapterImage]()
    @Published var isLoading = true
    @Published var showToolBar = false
    @Published var tabIndex: SourceChapterImage = .init(index: 0, imageUrl: "")
    @Published var direction: ReadingDirection = .vertical
    @Published var showReaderDirectionChoice = false

    private var scraper: Scraper
    private var manga: Manga
    private var chapters: [MangaChapter]

    init(manga: Manga, chapter: MangaChapter, scraper: Scraper, chapters: [MangaChapter]) {
        self.chapter = chapter
        self.chapters = chapters.sorted(by: \.position, using: >)
        self.manga = manga
        self.scraper = scraper
        self.direction = manga.getDefaultReadingDirection()
    }
    
    @MainActor
    func fetchChapter() async {
        if !isLoading { isLoading = true }

        do {
            images = try await scraper.asSource()!.fetchChapterImages(mangaId: manga.mangaId, chapterId: chapter.chapterId)
            tabIndex = images.first ?? .init(index: 0, imageUrl: "")

            images.forEach { ImagePipeline.inMemory.loadImage(with: $0.imageUrl, completion: { _ in }) }
        } catch {
            print(error)
            Logger.reader.info("Error loading chapter \(self.chapter.chapterId): \(error.localizedDescription)")
        }
        
        isLoading.toggle()
    }
    
    func progressBarCurrent() -> Double {
        return Double(images.firstIndex { $0 == tabIndex } ?? 0) + 1
    }

    func updateChapterStatus(image: SourceChapterImage) {
        if images.last != image && showToolBar == true && images.first != image {
            withAnimation {
                showToolBar = false
            }
        }

        if images.last == image {
            toggleToolbar()

            Task {
                do {
                    try await database.write { db in
                        try MangaChapter.markChapterAs(newStatus: .read, db: db, chapterId: self.chapter.id)
                    }
                } catch(let err) {
                    print(err)
                }
            }
        }
    }
    
    func getImagesOrderForDirection() -> [SourceChapterImage] {
        return direction == .rightToLeft ? images.reversed() : images
    }
    
    func toggleToolbar() {
        withAnimation {
            showToolBar.toggle()
        }
    }
    
    func goToChapter(_ goToDirection: GoToChapterDirection) {
        switch goToDirection {
        case .next:
            let foundChapters = chapters
                .filter {
                    switch direction {
                    case .rightToLeft:
                        return $0.position > chapter.position
                    case .leftToRight, .vertical:
                        return $0.position < chapter.position
                    }
                }
            
            if let foundChapter = direction == .rightToLeft ? foundChapters.last : foundChapters.first {
                self.chapter = foundChapter
            }
        case .previous:
            let foundChapters = chapters
                .filter {
                    switch direction {
                    case .rightToLeft:
                        return $0.position < chapter.position
                    case .leftToRight, .vertical:
                        return $0.position > chapter.position
                    }
                }
            
            if let foundChapter = direction == .rightToLeft ? foundChapters.first : foundChapters.last {
                self.chapter = foundChapter
            }
        }
    }
    
    func hasPreviousChapter() -> Bool {
        switch direction {
        case .rightToLeft:
            return chapters.last?.id != chapter.id
        case .leftToRight, .vertical:
            return chapters.first?.id != chapter.id
        }
    }
    
    func hasNextChapter() -> Bool {
        switch direction {
        case .rightToLeft:
            return chapters.first?.id != chapter.id
        case .leftToRight, .vertical:
            return chapters.last?.id != chapter.id
        }
    }
}
