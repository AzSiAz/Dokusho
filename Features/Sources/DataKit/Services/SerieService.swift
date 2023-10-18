import Foundation
import SwiftData
import OSLog

@Observable
public class SerieService {
    public static let shared = SerieService()
    
    private let logger = Logger.scraperService
    
    private init() {}

    @MainActor
    public func upsert(source: Source, serieId: String, in container: ModelContainer? = nil) async throws -> PersistentIdentifier {
        let context = ModelContext(container ?? .dokusho())
        context.autosaveEnabled = false
        
        guard 
            let result = try? context.fetch(.serieBySourceIdAndInternalId(scraperId: source.id, id: serieId)),
            let serie = result.first
        else {
            let data = try await source.fetchSerieDetail(serieId: serieId)
            let chapters = data.chapters.map { SerieChapter(from: $0) }
            let serie = Serie(from: data, scraperId: source.id, chapters: chapters)
            
            context.insert(serie)
            
            try context.save()
            
            return serie.persistentModelID
        }
        
        return serie.persistentModelID
    }

    @MainActor
    public func update(source: Source, serieId: String, in container: ModelContainer? = nil) async throws {
        let context = ModelContext(container ?? .dokusho())
        context.autosaveEnabled = false
        
        guard
            let result = try? context.fetch(.serieBySourceIdAndInternalId(scraperId: source.id, id: serieId)),
            let serie = result.first,
            let data = try? await source.fetchSerieDetail(serieId: serieId)
        else { return }

        serie.update(from: data)
        
        guard
            !data.chapters.isEmpty,
            let chapters = try? context.fetch(.chaptersForSerie(serieId: serieId, scraperId: source.id))
        else { return }

        for sourceChapter in data.chapters {
            if let dbChapter = chapters.first(where: { $0.internalId == sourceChapter.id }) {
                dbChapter.update(from: sourceChapter)
            } else {
                let dbChapter = SerieChapter(from: sourceChapter)
                serie.chapters?.append(dbChapter)
            }
        }
        
        for dbChapter in chapters {
            if (data.chapters.first(where: { $0.id == dbChapter.internalId }) != nil) { continue }
            context.delete(dbChapter)
        }
        
        try context.save()
    }
}
