import Foundation
import SwiftData
import SwiftUI

public extension ModelConfiguration {
    static func localConfiguration(inMemory: Bool = false) -> ModelConfiguration {
        ModelConfiguration(
            "Local",
            schema: Schema([Scraper.self]),
            isStoredInMemoryOnly: inMemory,
            allowsSave: true,
            groupContainer: .automatic,
            cloudKitDatabase: .none
        )
    }

    static func cloudConfiguration(inMemory: Bool = false) -> ModelConfiguration {
        ModelConfiguration(
            "Cloud",
            schema: Schema([SerieCollection.self, Serie.self, SerieChapter.self]),
            isStoredInMemoryOnly: inMemory,
            allowsSave: true,
            groupContainer: .automatic,
            cloudKitDatabase: .none
        )
    }
}

public extension ModelContainer {
    static func dokusho(inMemory: Bool = false) -> ModelContainer {
        return try! ModelContainer(
            for: Schema([Scraper.self, SerieCollection.self, Serie.self, SerieChapter.self])
//            configurations: [.localConfiguration(inMemory: inMemory), .cloudConfiguration(inMemory: inMemory)]
        )
    }
}
