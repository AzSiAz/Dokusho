import Foundation
import SwiftUI

class MangaSourceService: ObservableObject {
    static let shared = MangaSourceService()
    
    @Published var list: [Source] = [MangaSeeSource()]
    @Published var searchInSource: String = ""
    
    func search() async -> [SourcePaginatedSmallManga] {
        return []
    }
    
    func getSource(sourceId: Int16) -> Source? {
        return list.first { $0.id == sourceId }
    }
}
