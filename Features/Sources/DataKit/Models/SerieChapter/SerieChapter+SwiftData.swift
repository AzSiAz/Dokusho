import Foundation
import SwiftData

public extension FetchDescriptor where T: SerieChapter {
    static func chaptersForSerie(serieId: String, scraperId: UUID) -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> {
                $0.serie?.internalID == serieId && $0.serie?.scraperID == scraperId
            },
            sortBy: [
                SortDescriptor(\.volume, order: .reverse),
                SortDescriptor(\.chapter, order: .reverse),
            ]
        )
    }
    
//    static func chapters(historyType: SerieChapterHistoryType, searchTerm: String) -> FetchDescriptor<T> {
//        var descriptor = FetchDescriptor()
//        
//        descriptor.sortBy = historyType == .all ? [.init(\.uploadedAt, order: .reverse)] : [.init(\.readAt, order: .reverse)]
//        descriptor.fetchLimit = 200
//        descriptor.predicate = historyType == .all ?
//        #Predicate<T> {
//            if !searchTerm.isEmpty { $0.serie!.title!.contains(searchTerm) }
//            else { true }
//        } :
//        #Predicate<T> {
//            if !searchTerm.isEmpty { $0.readAt != nil && $0.serie!.title!.contains(searchTerm) }
//            else { $0.readAt != nil }
//        }
//        
//        return descriptor
//    }
}
