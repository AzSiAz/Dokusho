import Foundation
import SwiftData
import SwiftUI

struct DokushoModelContainerViewModifier: ViewModifier {
    let container: ModelContainer
    
    init(inMemory: Bool) {
//        let localConfiguration = ModelConfiguration(
//            "Local",
//            schema: Schema([Scraper.self]),
//            isStoredInMemoryOnly: inMemory,
//            allowsSave: true,
//            groupContainer: .automatic,
//            cloudKitDatabase: .none
//        )
//        
//        let cloudConfiguration = ModelConfiguration(
//            "Cloud",
//            schema: Schema([MangaCollection.self]),
//            isStoredInMemoryOnly: inMemory,
//            allowsSave: true,
//            groupContainer: .automatic,
//            cloudKitDatabase: .automatic
//        )

        container = try! ModelContainer(
//            for: Schema([Scraper.self], version: .init(0, 0, 1)),
            for: Schema([Scraper.self, MangaCollection.self, Manga.self])
//            migrationPlan: nil,
//            configurations: [localConfiguration, cloudConfiguration]
        )
    }
    
    func body(content: Content) -> some View {
        content
            .modelContainer(container)
    }
}

extension View {
    public func dokushoModelContainer(inMemory: Bool = false) -> some View {
        modifier(DokushoModelContainerViewModifier(inMemory: inMemory))
    }
}
