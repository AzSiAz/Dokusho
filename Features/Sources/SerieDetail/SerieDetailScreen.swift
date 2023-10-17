import SwiftUI
import DataKit

public struct SerieDetailScreen: View {
    @Environment(\.modelContext) var modelContext
    @Environment(ScraperService.self) var scraperService
    @Environment(SerieService.self) var serieService

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
        do {
            let context = ModelContext(modelContext.container)

            guard
                let source = scraperService.getSource(sourceId: scraperId),
                let scraper = try context.fetch(.getScrapersBySourceId(id: scraperId)).first,
                let id = try? await serieService.upsert(source: source, serieId: serieId, in: modelContext.container),
                let serie = modelContext.model(for: id) as? Serie,
                let scraper = modelContext.model(for: scraper.persistentModelID) as? Scraper
            else { return }
            
            withAnimation {
                self.serie = serie
                self.scraper = scraper
            }
        } catch {
            print(error)
        }
    }
}
