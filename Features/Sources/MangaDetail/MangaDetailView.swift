import SwiftUI
import DataKit

public struct MangaDetailScreen: View {
    @Environment(\.modelContext) var modelContext
    @Environment(ScraperService.self) var scraperService
    
    @State var scraper: Scraper? = nil
    @State var manga: Serie? = nil

    var mangaId: String
    var scraperId: UUID
    
    public init(mangaId: String, scraperId: UUID) {
        self.mangaId = mangaId
        self.scraperId = scraperId
    }
    
    public var body: some View {
        Group {
            if let manga, let scraper {
                InnerMangaDetail(manga: manga, scraper: scraper)
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await upsert() }
    }
}

private extension MangaDetailScreen {
    @MainActor
    func upsert() async {
        guard
            let source = scraperService.getSource(sourceId: scraperId),
            let found = try? modelContext.fetch(.getScrapersBySourceId(id: scraperId)),
            let scraper = found.first
        else { return }
        
        self.scraper = scraper
        
        guard
            let found = try? modelContext.fetch(.seriesBySourceId(scraperId: scraper.id, id: mangaId)),
            let manga = found.first
        else {
            guard let sourceManga = try? await source.fetchMangaDetail(id: mangaId) else { return }
            
            let manga = Serie(from: sourceManga, scraperId: scraper.id)
            modelContext.insert(manga)
            self.manga = manga
            
            return
        }
        
        self.manga = manga
    }
}
