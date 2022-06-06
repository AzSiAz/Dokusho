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
import DataKit
import Common

enum GoToChapterDirection {
    case next, previous
}

public class ReaderVM: ObservableObject {
    private let database = AppDatabase.shared.database
    
    @Published var chapter: MangaChapter
    @Published var images = [String]()
    @Published var isLoading = true
    @Published var showToolBar = false
    @Published var tabIndex: String = ""
    @Published var direction: ReadingDirection = .vertical
    @Published var showReaderDirectionChoice = false

    var manga: Manga
    private var scraper: Scraper
    private var chapters: [MangaChapter]
    private var runningTask: Task<(), Never>?

    public init(manga: Manga, chapter: MangaChapter, scraper: Scraper, chapters: [MangaChapter]) {
        self.chapter = chapter
        self.chapters = chapters.sorted(by: \.position, using: >)
        self.manga = manga
        self.scraper = scraper
        self.direction = manga.getDefaultReadingDirection()
    }
    
    @MainActor
    func fetchChapter() async {
        runningTask?.cancel()

        if !isLoading { isLoading = true }

        do {
            guard let data = try await scraper.asSource()?.fetchChapterImages(mangaId: manga.mangaId, chapterId: chapter.chapterId) else { throw "Error fetching image for scraper" }
            guard let firstImage = data.first else { throw "First image not found" }

            images = data.map { $0.imageUrl }
            tabIndex = firstImage.imageUrl
            
            backgroundFetchImage()
        } catch {
            Logger.reader.info("Error loading chapter \(self.chapter.chapterId): \(error.localizedDescription)")
        }
        
        if isLoading { isLoading = false }
    }
    
    func backgroundFetchImage() {
        runningTask = Task {
            for image in images {
                if Task.isCancelled { break }

                Logger.reader.info("Loading \(image)")
                _ = try? await ImagePipeline.inMemory.image(for: image)
            }
        }
    }
    
    func progressBarCurrent() -> Double {
        return Double(images.firstIndex { $0 == tabIndex } ?? 0) + 1
    }

    func updateChapterStatus(image: String) {
        if images.last == image {
            withAnimation {
                showToolBar = true
            }

            Task(priority: .background) {
                do {
                    try await self.database.write { db in
                        try MangaChapter.markChapterAs(newStatus: .read, db: db, chapterId: self.chapter.id)
                    }
                } catch(let err) {
                    print(err)
                }
            }
        }
    }
    
    func getImagesOrderForDirection() -> [String] {
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
                changeChapters(chapter: foundChapter)
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
                changeChapters(chapter: foundChapter)
            }
        }
    }

    func changeChapters(chapter: MangaChapter) {
        withAnimation {
            self.images = []
            self.tabIndex = ""
            self.chapter = chapter
            self.showToolBar = true
        }
        
        withAnimation(.default.delay(0.5)) {
            self.showToolBar = false
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
