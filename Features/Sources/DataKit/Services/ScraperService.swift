import Foundation
import SwiftData
import SerieScraper
import OSLog

@Observable
public class ScraperService {
    public static let shared = ScraperService()

    #if DEBUG
    @ObservationIgnored
    public var sources: [Source] = [NepNepSource.mangasee123, NepNepSource.manga4life, MangaDexSource.mangadex, MockSource.mock]
    #else
    @ObservationIgnored
    public var sources: [Source] = [NepNepSource.mangasee123, NepNepSource.manga4life, MangaDexSource.mangadex]
    #endif

    private let logger = Logger.scraperService
    
    private init() {}

    public func getSource(sourceId: UUID) -> Source? {
        return sources.first { $0.id == sourceId }
    }

    public func upsertAllSource() {
        do {
            let context = ModelContext(.dokusho())
            let scrapers = try context.fetch(.allScrapers())

            for source in sources {
                if let scraper = scrapers.first(where: { $0.id == source.id }) {
                    logger.debug("Updating source: \(scraper.name)")
                    scraper.update(source: source)
                } else {
                    logger.debug("Inserting source: \(source.name)")
                    context.insert(Scraper(source: source, isActive: false))
                }
            }

            try context.save()
        } catch {
            logger.error("Error upserting scrapers: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func onMove(offsets: IndexSet, position: Int) {
        do {
            let context = ModelContext(.dokusho())
            var scrapers = try context.fetch(.activeScrapersByPosition())
            scrapers.move(fromOffsets: offsets, toOffset: position)
            
            for (position, scraper) in scrapers.enumerated() {
                scraper.position = position
            }
        } catch {
            logger.error("Error changing scraper order: \(error.localizedDescription)")
        }
    }
}
