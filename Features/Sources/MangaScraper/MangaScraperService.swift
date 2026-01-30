import Foundation

public class MangaScraperService {
    nonisolated(unsafe) public static let shared = MangaScraperService()

    public var list: [Source] {
        var sources: [Source] = [
            NepNepSource.MangaSee123Source,
            NepNepSource.Manga4LifeSource,
            MangaDex.shared
        ]

        if TsundokuConfiguration.shared.isConfigured {
            sources.append(TsundokuDirect.shared)
            sources.append(WeebCentralTsundoku.shared)
        }

        return sources
    }

    public func getSource(sourceId: UUID) -> Source? {
        return list.first { $0.id == sourceId }
    }
}
