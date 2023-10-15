import Foundation
import SwiftUI
import SerieScraper
import DataKit
import Collections
import Common

@MainActor
@Observable
class ExploreSourceViewModel {
    func addToCollection(smallManga: SourceSmallSerie, collection: SerieCollection) async {
//        guard let sourceManga = try? await scraper.asSource()?.fetchMangaDetail(id: smallManga.id) else { return }
//
//        do {
//            try await database.write { db -> Void in
//                guard var manga = try MangaDB.all().forMangaId(smallManga.id, self.scraper.id).fetchOne(db) else {
//                    var manga = try MangaDB.updateFromSource(db: db, scraper: self.scraper, data: sourceManga)
//                    try manga.updateChanges(db) {
//                        $0.mangaCollectionId = collection.id
//                    }
//                    return
//                }
//
//                try manga.updateChanges(db) {
//                    $0.mangaCollectionId = collection.id
//                }
//            }
//        } catch(let err) {
//            print(err)
//        }
    }
}
