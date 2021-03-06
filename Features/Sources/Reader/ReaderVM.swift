//
//  ReaderVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import Foundation
import SwiftUI
import OSLog
import MangaScraper
import Nuke
import DataKit
import Common

enum GoToChapterDirection {
    case next, previous
}

enum ReaderLink: Equatable, Hashable {
    case next(chapter: MangaChapter)
    case previous(chapter: MangaChapter)
    case image(url: String)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .next(let chapter):
            hasher.combine(chapter.id)
        case .previous(let chapter):
            hasher.combine(chapter.id)
        case .image(let url):
            hasher.combine(url)
        }
    }
}

public class ReaderVM: ObservableObject {
    private let database = AppDatabase.shared.database
    
    @Published var currentChapter: MangaChapter
    @Published var images = [ReaderLink]()
    @Published var isLoading = true
    @Published var showToolBar = false
    @Published var tabIndex = ReaderLink.image(url: "")
    @Published var direction: ReadingDirection = .vertical
    @Published var showReaderDirectionChoice = false

    var manga: Manga
    private var scraper: Scraper
    private var chapters: [MangaChapter]
    private var runningTask: Task<(), Never>?

    public init(manga: Manga, chapter: MangaChapter, scraper: Scraper, chapters: [MangaChapter]) {
        self.currentChapter = chapter
        self.chapters = chapters.sorted(by: \.position, using: >)
        self.manga = manga
        self.scraper = scraper
        self.direction = manga.getDefaultReadingDirection()
    }
    
    func cancelTasks() {
        runningTask?.cancel()
    }
    
    func fetchChapter() async {
        cancelTasks()

        if !isLoading {
            await asyncChange {
                self.isLoading = true
            }
        }

        do {
            guard let data = try await scraper.asSource()?.fetchChapterImages(mangaId: manga.mangaId, chapterId: currentChapter.chapterId) else { throw "Error fetching image for scraper" }

            let urls = data.map { $0.imageUrl }
            let readerLinks = try buildReaderLinks(data: urls)
            
            await asyncChange {
                self.images = readerLinks
            }
            
            guard let firstImage = getOnlyImagesUrl().first else { throw "First Image not found" }
            await asyncChange {
                self.tabIndex = firstImage
            }
            
            backgroundFetchImage(urls)
        } catch {
            Logger.reader.info("Error loading chapter \(self.currentChapter.chapterId): \(error)")
        }
        
        if isLoading {
            await asyncChange {
                self.isLoading = false
            }
        }
    }
    
    func buildReaderLinks(data: [String]) throws -> [ReaderLink] {
        var base = [ReaderLink]()
        base.append(contentsOf: data.map { ReaderLink.image(url: $0) })
        
        switch direction {
        case .rightToLeft:
            if let previousChapter = getChapter(.next) {
                base.insert(.previous(chapter: previousChapter), at: 0)
            }
            if let nextChapter = getChapter(.previous) {
                base.append(.next(chapter: nextChapter))
            }
        case .leftToRight, .vertical:
            if let previousChapter = getChapter(.previous) {
                base.insert(.previous(chapter: previousChapter), at: 0)
            }
            if let nextChapter = getChapter(.next) {
                base.append(.next(chapter: nextChapter))
            }
        }

        return base
    }
    
    func backgroundFetchImage(_ urls: [String]) {
        runningTask = Task {
            for image in urls {
                if Task.isCancelled { break }

                Logger.reader.info("Loading \(image)")
                _ = try? await ImagePipeline.inMemory.image(for: image.asImageRequest())
            }
        }
    }
    
    func progressBarCurrent() -> Double {
        let onlyUrl = getOnlyImagesUrl()

        switch tabIndex {
        case .next(_):
            return Double(onlyUrl.count)
        case .previous(_):
            return 1
        case .image(_):
            let currentCount = onlyUrl.firstIndex(of: tabIndex) ?? 0
            return Double(currentCount+1)
        }
    }
    
    func progressBarCount() -> Double {
        let onlyUrl = getOnlyImagesUrl()
        return Double(onlyUrl.count)
    }

    func updateChapterStatus(image: ReaderLink) {
        if progressBarCount() == progressBarCurrent() {
            withAnimation {
                showToolBar = true
            }

            Task(priority: .background) {
                do {
                    try await self.database.write { db in
                        try MangaChapter.markChapterAs(newStatus: .read, db: db, chapterId: self.currentChapter.id)
                    }
                } catch(let err) {
                    print(err)
                }
            }
        }
    }
    
    func getImagesOrderForDirection() -> [ReaderLink] {
        return direction == .rightToLeft ? images.reversed() : images
    }
    
    func toggleToolbar() {
        withAnimation {
            showToolBar.toggle()
        }
    }
    
    func getChapters(_ goToDirection: GoToChapterDirection? = nil) -> [MangaChapter] {
        switch goToDirection {
        case .next:
            let foundChapters = chapters
                .filter {
                    switch direction {
                    case .rightToLeft:
                        return $0.position > currentChapter.position
                    case .leftToRight, .vertical:
                        return $0.position < currentChapter.position
                    }
                }
            
            return foundChapters
        case .previous:
            let foundChapters = chapters
                .filter {
                    switch direction {
                    case .rightToLeft:
                        return $0.position < currentChapter.position
                    case .leftToRight, .vertical:
                        return $0.position > currentChapter.position
                    }
                }
            
            return foundChapters
        default: return chapters.reversed()
        }
    }
    
    func getChapter(_ goToDirection: GoToChapterDirection) -> MangaChapter? {
        switch goToDirection {
        case .next:
            let foundChapters = getChapters(goToDirection)

            if let foundChapter = (direction == .rightToLeft ? foundChapters.last : foundChapters.first) {
                return foundChapter
            }
        case .previous:
            let foundChapters = getChapters(goToDirection)

            if let foundChapter = (direction == .rightToLeft ? foundChapters.first : foundChapters.last) {
                return foundChapter
            }
        }
        
        return nil
    }
    
    func goToChapter(_ goToDirection: GoToChapterDirection) {
        guard let chapter = getChapter(goToDirection) else { return }
        changeChapters(chapter: chapter)
    }
    
    func goToChapter(to chapter: MangaChapter) {
        if chapter != currentChapter {
            changeChapters(chapter: chapter)
        }
    }

    func changeChapters(chapter: MangaChapter) {
        withAnimation {
            self.images = []
            self.currentChapter = chapter
            self.tabIndex = ReaderLink.image(url: "")
            self.showToolBar = true
        }
        
        withAnimation(.default.delay(0.5)) {
            self.showToolBar = false
        }
    }
    
    func hasPreviousChapter() -> Bool {
        switch direction {
        case .rightToLeft:
            return chapters.last?.id != currentChapter.id
        case .leftToRight, .vertical:
            return chapters.first?.id != currentChapter.id
        }
    }
    
    func hasNextChapter() -> Bool {
        switch direction {
        case .rightToLeft:
            return chapters.first?.id != currentChapter.id
        case .leftToRight, .vertical:
            return chapters.last?.id != currentChapter.id
        }
    }
    
    func updateTabIndex(index: Int) {
        let found = images[index]
        if case .image(_) = found {
            tabIndex = found
        }
    }
    
    func updateTabIndex(image: ReaderLink) {
        if let index = images.firstIndex(of: image) {
            self.updateTabIndex(index: index)
        }
    }
    
    func getOnlyImagesUrl() -> [ReaderLink] {
        return images.filter { if case .image(_) = $0 { return true } else { return false } }
    }
    
    func setReadingDirection(new direction: ReadingDirection) {
        self.direction = direction
    }
}
