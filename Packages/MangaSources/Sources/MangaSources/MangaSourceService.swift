import Foundation
import SwiftUI

public class MangaSourceService: ObservableObject {
    public static let shared = MangaSourceService()
    
    @Published public var list: [Source] = [NepNepSource.MangaSee123Source, NepNepSource.Manga4LifeSource]
    @Published public var searchInSource: String = ""
    
    public init() {}
    
    public func search() async -> [SourcePaginatedSmallManga] {
        return []
    }
    
    public func getSource(sourceId: Int) -> Source? {
        return list.first { $0.id == sourceId }
    }
}
