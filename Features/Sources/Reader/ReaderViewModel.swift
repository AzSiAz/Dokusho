import Foundation
import SwiftUI
import OSLog
import SerieScraper
import Nuke
import DataKit
import Common

enum GoToChapterDirection {
    case next, previous
}

enum ReaderLink: Equatable, Hashable {
    case next(chapter: SerieChapter)
    case previous(chapter: SerieChapter)
    case image(url: URL?)
    
//    func hash(into hasher: inout Hasher) {
//        switch self {
//        case .next(let chapter):
//            hasher.combine(chapter.id)
//        case .previous(let chapter):
//            hasher.combine(chapter.id)
//        case .image(let url):
//            hasher.combine(url)
//        }
//    }
}

@Observable
public class ReaderViewModel {
    let serie: Serie
    let scraper: Scraper
    let chapters: [SerieChapter]
    
    var currentChapter: SerieChapter
    var images = [ReaderLink]()
    var isLoading = true
    var showToolBar = false
    var tabIndex = ReaderLink.image(url: nil)
    var showReaderDirectionChoice = false

    public init(serie: Serie, chapter: SerieChapter, scraper: Scraper, chapters: [SerieChapter]) {
        self.currentChapter = chapter
        self.chapters = chapters
        self.serie = serie
        self.scraper = scraper
    }
    
    func cancelTasks() {
        ImagePipeline.inMemory.cache.removeAll(caches: [.all])
    }
    
    func fetchChapter() async {
        cancelTasks()

        self.isLoading = true

        do {
            guard
                let source = ScraperService.shared.getSource(sourceId: scraper.id),
                let data = try? await source.fetchChapterImages(serieId: serie.internalID, chapterId: currentChapter.internalID)
            else { throw "Error fetching image for scraper" }

            let urls = data.map { $0.imageUrl }
            
            self.images = try buildReaderLinks(data: urls)
            
            guard let firstImage = getOnlyImagesUrl().first else { throw "First Image not found" }
            self.tabIndex = firstImage
        } catch {
            Logger.reader.info("Error loading chapter \(self.currentChapter.internalID): \(error)")
        }

        if isLoading {
            self.isLoading = false
        }
    }
    
    func buildReaderLinks(data: [URL]) throws -> [ReaderLink] {
        var images = [ReaderLink]()
        let (previous, next) = getAdjacentChapters()
        
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

//            do {
//                try await self.database.write { [currentChapter] db in
//                    try MangaChapterDB.markChapterAs(newStatus: .read, db: db, chapterId: currentChapter.id)
//                }
//            } catch(let err) {
//                print(err)
//            }
        }
    }
    
    func getImagesOrderForDirection() -> [ReaderLink] {
        return serie.readerDirection == .rightToLeft ? images.reversed() : images
    }
    
    func toggleToolbar() {
        withAnimation {
            showToolBar.toggle()
        }
    }
    
    func getAdjacentChapters() -> (previous: SerieChapter?, next: SerieChapter?) {
        switch serie.readerDirection {
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
    
    func getChapters(_ goToDirection: GoToChapterDirection? = nil) -> [SerieChapter] {
        switch goToDirection {
        case .next:
            let foundChapters = chapters
                .filter {
                    let volume = $0.volume ?? 0
                    let chapter = $0.chapter
                    let currentVolume = currentChapter.volume ?? 0
                    let currentChapter = currentChapter.chapter

                    switch serie.readerDirection {
                    case .rightToLeft: return volume > currentVolume && chapter > currentChapter
                    case .leftToRight, .vertical: return volume < currentVolume && chapter < currentChapter
                    }
                }
            
            return foundChapters
        case .previous:
            let foundChapters = chapters
                .filter {
                    let volume = $0.volume ?? 0
                    let chapter = $0.chapter
                    let currentVolume = currentChapter.volume ?? 0
                    let currentChapter = currentChapter.chapter

                    switch serie.readerDirection {
                    case .rightToLeft: return volume < currentVolume && chapter < currentChapter
                    case .leftToRight, .vertical: return volume > currentVolume && chapter > currentChapter
                    }
                }
            
            return foundChapters
        default: return chapters.reversed()
        }
    }
    
    func getChapter(_ goToDirection: GoToChapterDirection) -> SerieChapter? {
        switch goToDirection {
        case .next:
            let foundChapters = getChapters(goToDirection)

            if let foundChapter = (serie.readerDirection == .rightToLeft ? foundChapters.last : foundChapters.first) {
                return foundChapter
            }
        case .previous:
            let foundChapters = getChapters(goToDirection)

            if let foundChapter = (serie.readerDirection == .rightToLeft ? foundChapters.first : foundChapters.last) {
                return foundChapter
            }
        }
        
        return nil
    }
    
    func goToChapter(_ goToDirection: GoToChapterDirection) {
        guard let chapter = getChapter(goToDirection) else { return }
        changeChapters(chapter: chapter)
    }
    
    func goToChapter(to chapter: SerieChapter) {
        if chapter != currentChapter {
            changeChapters(chapter: chapter)
        }
    }

    func changeChapters(chapter: SerieChapter) {
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
        switch serie.readerDirection {
        case .rightToLeft: return chapters.last?.id != currentChapter.id
        case .leftToRight, .vertical: return chapters.first?.id != currentChapter.id
        }
    }
    
    func hasNextChapter() -> Bool {
        switch serie.readerDirection {
        case .rightToLeft: return chapters.first?.id != currentChapter.id
        case .leftToRight, .vertical: return chapters.last?.id != currentChapter.id
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
}
