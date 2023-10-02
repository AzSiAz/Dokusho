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
    case image(url: URL?)
    
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

@Observable
public class ReaderViewModel {
    private let database = AppDatabase.shared.database
    let manga: Manga
    let scraper: Scraper
    let chapters: [MangaChapter]
    
    var currentChapter: MangaChapter
    var images = [ReaderLink]()
    var isLoading = true
    var showToolBar = false
    var tabIndex = ReaderLink.image(url: nil)
    var direction: ReadingDirection = .vertical
    var showReaderDirectionChoice = false

    public init(manga: Manga, chapter: MangaChapter, scraper: Scraper, chapters: [MangaChapter]) {
        self.currentChapter = chapter
        self.chapters = chapters.sorted(by: \.position, using: >)
        self.manga = manga
        self.scraper = scraper
        self.direction = manga.getDefaultReadingDirection()
    }
    
    func cancelTasks() {
        ImagePipeline.inMemory.cache.removeAll(caches: [.all])
    }
    
    func fetchChapter() async {
        cancelTasks()

        self.isLoading = true

        do {
            guard let data = try await scraper.asSource()?.fetchChapterImages(mangaId: manga.mangaId, chapterId: currentChapter.chapterId) else { throw "Error fetching image for scraper" }

            let urls = data.map { $0.imageUrl }
            
            self.images = try buildReaderLinks(data: urls)
            
            guard let firstImage = getOnlyImagesUrl().first else { throw "First Image not found" }
            self.tabIndex = firstImage
        } catch {
            Logger.reader.info("Error loading chapter \(self.currentChapter.chapterId): \(error)")
        }

        if isLoading {
            self.isLoading = false
        }
    }
    
    func buildReaderLinks(data: [URL]) throws -> [ReaderLink] {
        var images = [ReaderLink]()
        let (previous, next) = getChapters()
        
        if let previous {
            images.append(.previous(chapter: previous))
        }

        images.append(contentsOf: data.map { .image(url: $0) })
        
        if let next {
            images.append(.next(chapter: next))
        }

        return images
    }
    
    func backgroundFetchImage() async {
        guard let currentImageIndex = self.images.firstIndex(of: self.tabIndex) else { return }
        let nextLoadingIndex = currentImageIndex <= self.images.endIndex && currentImageIndex != 0 ? self.images.index(after: currentImageIndex) : currentImageIndex
        let imagesToLoad = self.images[nextLoadingIndex...].prefix(UserPreferences.shared.numberOfPreloadedImages)
        
        for image in imagesToLoad {
            if Task.isCancelled { break }
            guard case let .image(url) = image, let url else { return }

            _ = try? await ImagePipeline.inMemory.image(for: url)
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
    
    func updateChapterStatus() async {
        if progressBarCount() == progressBarCurrent() {
            withAnimation {
                self.showToolBar = true
            }

            do {
                try await self.database.write { [currentChapter] db in
                    try MangaChapter.markChapterAs(newStatus: .read, db: db, chapterId: currentChapter.id)
                }
            } catch(let err) {
                print(err)
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
    
    func getChapters() -> (previous: MangaChapter?, next: MangaChapter?) {
        switch direction {
        case .rightToLeft:
            let previousChapter = getChapter(.next)
            let nextChapter = getChapter(.previous)

            return (previous: previousChapter, next: nextChapter)
        case .leftToRight, .vertical:
            let previousChapter = getChapter(.previous)
            let nextChapter = getChapter(.next)
            
            return (previous: previousChapter, next: nextChapter)
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
        self.isLoading = true
        
        withAnimation {
            self.images = []
            self.currentChapter = chapter
            self.tabIndex = ReaderLink.image(url: nil)
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
