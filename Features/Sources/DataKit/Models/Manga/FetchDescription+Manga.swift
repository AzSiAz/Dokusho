import Foundation
import SwiftData

public extension FetchDescriptor where T: Manga {
    static func mangaInCollection(scraperId: UUID?) -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> {
                $0.scraperId == scraperId && $0.collection != nil
            }
        )
    }
    
    static func mangaBySourceId(scraperId: UUID, id: String) -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> {
                $0.scraperId == scraperId && $0.mangaId == id
            }
        )
    }
}
