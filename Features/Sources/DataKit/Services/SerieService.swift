import Foundation
import SwiftData
import OSLog

@Observable
public class SerieService {
private let logger = Logger.serieService
    
    public init() {}

    @discardableResult
    public func upsert(source: Source, serieInternalID: Serie.InternalID, in container: ModelContainer? = nil) async throws -> Serie {
        let context = ModelContext(container ?? .dokusho())
        guard
            let series = try? context.fetch(.serieBySourceIdAndInternalId(scraperId: source.id, id: serieInternalID)),
            let serie = series.first
        else {
            let sourceData = try await source.fetchSerieDetail(serieId: serieInternalID)
            let serie = Serie(from: sourceData, scraperID: source.id)
            let chapters = sourceData.chapters.map { SerieChapter(from: $0, serie: serie) }
            serie.chapters = chapters

            context.insert(serie)

            return serie
        }
        
        if context.hasChanges { try context.save() }

        return serie
    }

    @discardableResult
    public func update(source: Source, serieInternalID: Serie.InternalID, in container: ModelContainer? = nil) async throws -> Serie {
        let context = ModelContext(container ?? .dokusho())
        guard
            let series = try? context.fetch(.serieBySourceIdAndInternalId(scraperId: source.id, id: serieInternalID)),
            let serie = series.first,
            let sourceData = try? await source.fetchSerieDetail(serieId: serieInternalID)
        else { throw "Something happened" }

        serie.update(from: sourceData)
        guard
            !sourceData.chapters.isEmpty,
            let chapters = try? context.fetch(.chaptersForSerie(serieId: serie.internalID, scraperId: source.id))
        else { return serie }

        for sourceChapter in sourceData.chapters {
            if let dbChapter = chapters.first(where: { $0.internalID == sourceChapter.id }) {
                dbChapter.update(from: sourceChapter)
            } else {
                let dbChapter = SerieChapter(from: sourceChapter, serie: serie)
                context.insert(dbChapter)
            }
        }

        for dbChapter in chapters {
            if (sourceData.chapters.first(where: { $0.id == dbChapter.internalID }) != nil) { continue }
            context.delete(dbChapter)
        }

        if context.hasChanges { try context.save() }
        
        return serie
    }
    
    public func addSerieToCollection(source: Source, serieInternalID: Serie.InternalID, serieCollection: SerieCollection, in container: ModelContainer) async throws {
        let serie = try await upsert(source: source, serieInternalID: serieInternalID, in: container)
        serie.collection = serieCollection
    }
}
