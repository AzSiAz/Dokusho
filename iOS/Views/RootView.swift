//
//  RootView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var libState: LibraryState
    @State var tabIndex = 2
    
    var body: some View {
        TabView(selection: $tabIndex) {
            LibraryView(vm: .init(libState: libState))
                .tabItem { Label("Library", systemImage: "books.vertical") }
                .tag(0)
            ExploreView()
                .tabItem { Label("Explore", systemImage: "safari") }
                .tag(1)
            SettingsView(vm: .init(libState: libState))
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(2)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
