import Foundation
import Harmony
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

    public func upsertAllSource(in harmonic: Harmonic) async {
        do {
            let scrapers = try await harmonic.reader.read { db in
                return try Scraper.all().fetchAll(db)
            }

            for source in sources {
                if let scraper = scrapers.first(where: { $0.id == source.id }) {
                    var sc = scraper
                    sc.update(source: source)
                    if sc != scraper {
                        logger.debug("Updating source: \(scraper.name)")
                        try await harmonic.save(record: sc)
                    }
                } else {
                    logger.debug("Inserting source: \(source.name)")
                    try await harmonic.create(record: Scraper(source: source))
                }
            }
        } catch {
            logger.error("Error upserting scrapers: \(error.localizedDescription)")
        }
    }

    public func onMove(scrapers: [Scraper], offsets: IndexSet, position: Int, in harmonic: Harmonic) async {
        do {
            var sc = scrapers
            // change the order of the items in the array
            sc.move(fromOffsets: offsets, toOffset: position)

            let updatedScrapers = sc
                .enumerated()
                .map { d in
                    var scraper = d.element
                    scraper.position = d.offset;
                    return scraper
                }
            
            try await harmonic.save(records: updatedScrapers)
        } catch {
            logger.error("Error changing scraper order: \(error.localizedDescription)")
        }
    }
}
