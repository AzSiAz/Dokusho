import Foundation
import SwiftData

public extension FetchDescriptor where T: Serie {
    static func seriesInCollection(scraperId: UUID?) -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> {
                $0.scraperId == scraperId && $0.collection != nil
            }
        )
    }
    
    static func seriesBySourceId(scraperId: UUID, id: String) -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> {
                $0.scraperId == scraperId && $0.mangaId == id
            }
        )
    }
    
    static func seriesForSerieCollection(collectionId: PersistentIdentifier) -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> {
                $0.collection?.id == collectionId
            }
        )
    }
}
