//
//  RootView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI

struct RootView: View {
    enum TabTag {
        case library
        case source
        case settings
    }
    
    @State var tabIndex: TabTag = .library
    
    var body: some View {
        TabView(selection: $tabIndex) {
            LibraryTabView(vm: .init())
                .tabItem { Label("Library", systemImage: "books.vertical") }
                .tag(TabTag.library)
            HistoryTabView()
                .tabItem { Label("History", systemImage: "clock") }
            ExploreTabView()
                .tabItem { Label("Explore", systemImage: "safari") }
                .tag(TabTag.source)
            SettingsTabView(vm: .init())
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(TabTag.settings)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
