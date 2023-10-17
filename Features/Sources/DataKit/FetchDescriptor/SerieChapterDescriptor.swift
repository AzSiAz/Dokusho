import Foundation
import SwiftData

public extension FetchDescriptor where T: SerieChapter {
    static func chaptersForSerie(serieId: String, scraperId: UUID) -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> {
                $0.serie?.internalId == serieId && $0.serie?.scraperId == scraperId
            },
            sortBy: [
                SortDescriptor(\.volume, order: .reverse),
                SortDescriptor(\.chapter, order: .reverse),
            ]
        )
    }
}
