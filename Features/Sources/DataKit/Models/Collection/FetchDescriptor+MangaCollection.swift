import Foundation
import SwiftData

public extension FetchDescriptor where T: SerieCollection {
    static func allMangaCollectionByPosition(_ direction: SortOrder = .forward) -> FetchDescriptor<T> {
        FetchDescriptor(
            sortBy: [
                SortDescriptor(\.position, order: .forward),
                SortDescriptor(\.name, order: .forward)
            ])
    }
}
