import Foundation

public class MangaScraperService {
    public static let shared = MangaScraperService()
    
    public var list: [Source] = [
        NepNepSource.MangaSee123Source,
        NepNepSource.Manga4LifeSource,
        MangaDex.shared
    ]
    
    public func getSource(sourceId: UUID) -> Source? {
        return list.first { $0.id == sourceId }
    }
}
