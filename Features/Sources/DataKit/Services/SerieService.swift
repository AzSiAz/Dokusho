import Foundation
import Harmony
import OSLog

@Observable
public class SerieService {
    public static let shared = SerieService()
    
    private let logger = Logger.serieService
    
    private init() {}

    public func upsert(source: Source, serieID: String, harmonic: Harmonic) async throws {
        guard var _ = try await harmonic.reader.read({ try Serie.all().whereSerie(serieID: serieID, scraperID: source.id).fetchOne($0) })
        else {
            let sourceData = try await source.fetchSerieDetail(serieId: serieID)
            let serie = Serie(from: sourceData, scraperID: source.id)
            let chapters = sourceData.chapters.map { SerieChapter(from: $0, serieID: serie.id) }

            try await harmonic.save(record: serie)
            try await harmonic.save(records: chapters)

            return
        }
        
        return
    }

    public func update(source: Source, serieID: String, harmonic: Harmonic) async throws {
        guard
            var serie = try await harmonic.reader.read({ try Serie.all().whereSerie(serieID: serieID, scraperID: source.id).fetchOne($0) }),
            let sourceData = try? await source.fetchSerieDetail(serieId: serieID)
        else { return }

        serie.update(from: sourceData)

        guard
            !sourceData.chapters.isEmpty,
            let chapters = try? await harmonic.reader.read({ [serie] in try SerieChapter.all().whereSerie(serieID: serie.id).fetchAll($0) })
        else { return }

        for sourceChapter in sourceData.chapters {
            if var dbChapter = chapters.first(where: { $0.internalID == sourceChapter.id }) {
                dbChapter.update(from: sourceChapter)
                try await harmonic.save(record: dbChapter)
            } else {
                let dbChapter = SerieChapter(from: sourceChapter, serieID: serie.id)
                try await harmonic.save(record: dbChapter)
            }
        }

        for dbChapter in chapters {
            if (sourceData.chapters.first(where: { $0.id == dbChapter.internalID }) != nil) { continue }
            try await harmonic.delete(record: dbChapter)
        }
    }
}
