import Foundation
import SwiftData

public extension FetchDescriptor where T: Scraper {
    static func activeScrapersByPosition() -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> { $0.isActive == true },
            sortBy: [
                SortDescriptor(\.position, order: .forward),
                SortDescriptor(\.name, order: .forward)
            ])
    }
    
    static func allScrapers() -> FetchDescriptor<T> {
        FetchDescriptor(sortBy: [
            SortDescriptor(\.position, order: .forward),
            SortDescriptor(\.name, order: .forward)
        ])
    }
    
    static func getScrapersBySourceId(id: UUID) -> FetchDescriptor<T> {
        FetchDescriptor(
            predicate: #Predicate<T> { $0.scraperId == id }
        )
    }
}
