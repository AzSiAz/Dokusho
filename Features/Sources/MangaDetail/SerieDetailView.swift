import SwiftUI
import DataKit

public struct SerieDetailScreen: View {
    @Environment(\.modelContext) var modelContext
    @Environment(ScraperService.self) var scraperService

    @State var scraper: Scraper? = nil
    @State var serie: Serie? = nil

    var serieId: String
    var scraperId: UUID

    public init(serieId: String, scraperId: UUID) {
        self.serieId = serieId
        self.scraperId = scraperId
    }

    public var body: some View {
        Group {
            if let serie, let scraper {
                InnerSerieDetail(serie: serie, scraper: scraper)
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await upsert() }
    }
}

private extension SerieDetailScreen {
    @MainActor
    func upsert() async {
        guard
            let source = scraperService.getSource(sourceId: scraperId),
            let found = try? modelContext.fetch(.getScrapersBySourceId(id: scraperId)),
            let scraper = found.first
        else { return }

        self.scraper = scraper

        guard
            let found = try? modelContext.fetch(.seriesBySourceId(scraperId: scraper.id, id: serieId)),
            let manga = found.first
        else {
            guard let sourceManga = try? await source.fetchSerieDetail(serieId: serieId) else { return }
            
            let manga = Serie(from: sourceManga, scraperId: scraper.id)
            modelContext.insert(manga)
            self.serie = manga

            return
        }

        self.serie = manga
    }
}
