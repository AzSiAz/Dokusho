//
//  RootView.swift
//  RootView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import Foundation
import SwiftUI
import MangaSources

struct RootView: View {
    enum ActiveTab {
        case explore, library, history, settings
    }
    
    @State var tab: ActiveTab = .explore
    
    var body: some View {
        TabView {
//            LibraryTabView()
//                .tabItem { Label("Library", systemImage: "books.vertical") }
//                .tag(ActiveTab.library)

            ExploreTabView()
                .tabItem { Label("Explore", systemImage: "safari") }
                .tag(ActiveTab.explore)
        }
        .task(priority: .high) {
            await SourceEntity.importFromService(sources: MangaSourceService.shared.list)
        }
    }
}
