import Foundation
import MangaSource


struct MiniSource: Identifiable, Hashable {
    var id: Int
    var sourceIndex: Int
    var name: String
    var lang: SourceLang
    var icon: String
    var active: Bool
    var supportLatest: Bool
}

class MangaSourceService: ObservableObject {
    static let shared = MangaSourceService()
    
    private var possibleSources: [Source] = [MangaSeeSource()]
    
    func getSourceList() -> [MiniSource] {
        return self.possibleSources.enumerated().map { (index, source) -> MiniSource in
            return MiniSource(id: source.id, sourceIndex: index, name: source.name, lang: source.lang, icon: source.icon, active: true, supportLatest: source.supportsLatest)
        }
    }
    
    func getSourceById(_ sourceId: Int) -> Source {
        var foundSource: Source = possibleSources[0]
        
        self.possibleSources.forEach { (source) in
            if source.id == sourceId {
                foundSource = source
            }
        }
        
        return foundSource
    }
    
    func getSourceByIndex(sourceIndex: Int) -> Source {
        return self.possibleSources[sourceIndex]
    }
    
    func fetchLatestUpdates(page: Int, sourceId: Int, _ completion: @escaping SourcePaginatedSmallMangaHandler) {
        let source = getSourceById(sourceId)

        return source.fetchLatestUpdates(page: page, completion: completion)
    }
    
    func fetchPopularManga(page: Int, sourceId: Int, _ completion: @escaping SourcePaginatedSmallMangaHandler) {
        let source = getSourceById(sourceId)

        return source.fetchPopularManga(page: page, completion: completion)
    }

    func getMangaDetail(id: String, sourceId: Int, _ completion: @escaping SourceMangaDetailHandler) {
        let source = getSourceById(sourceId)

        return source.fetchMangaDetail(id: id, completion: completion)
    }

    func getMangaChapterImages(chapterId: String, mangaId: String, sourceId: Int, _ completion: @escaping SourceChapterImagesHandler) {
        let source = getSourceById(sourceId)

        source.fetchChapterImages(mangaId: mangaId, chapterId: chapterId, completion: completion)
    }
}
