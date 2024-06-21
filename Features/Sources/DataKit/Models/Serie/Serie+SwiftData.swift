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
    
    static func serieBySourceIdAndInternalId(scraperId: UUID, id: Serie.InternalID) -> FetchDescriptor<T> {
        let descriptor = FetchDescriptor(
            predicate: #Predicate<T> {
                $0.scraperId == scraperId && $0.internalId == id
            }
        )
        
        descriptor.fetchLimit = 1
        
        return descriptor
    }
    
    static func seriesForSerieCollection(collectionId: SerieCollection.ID) -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> {
                $0.collection?.id == collectionId
            }
        )
    }
}
