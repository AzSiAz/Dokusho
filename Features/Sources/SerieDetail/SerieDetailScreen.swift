import SwiftUI
import DataKit

public struct SerieDetailScreen: View {
    @Environment(ScraperService.self) var scraperService
    @Environment(SerieService.self) var serieService
    
    @Harmony var harmony
    
    @Query<OneSerieWithDetailRequest> var serie: SerieWithDetail?

    @State var isError: Bool = false
    
    var serieID: String
    var scraperID: Scraper.ID

    public init(serieID: String, scraperID: UUID) {
        self.serieID = serieID
        self.scraperID = scraperID
        self._serie = Query(OneSerieWithDetailRequest(serieID: serieID, scraperID: scraperID))
    }

    public var body: some View {
        Group {
            if let serie {
                InnerSerieDetail(data: serie)
            } else {
                ProgressView()
            }
            
            if isError {
                ScrollView {
                    ContentUnavailableView("Something happened, try to refresh maybe ?", systemImage: "arrow.clockwise")
                }
                .refreshable { await upsert() }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await upsert() }
    }
}

private extension SerieDetailScreen {
    func upsert() async {
        withAnimation {
            isError = false
        }

        do {
            guard let source = scraperService.getSource(sourceId: scraperID) else { return }
            
            try await serieService.upsert(source: source, serieID: serieID, harmonic: harmony)
        } catch {
            withAnimation {
                isError = true
            }
        }
    }
}
