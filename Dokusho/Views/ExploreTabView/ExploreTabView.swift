//
//  ContentView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI
import MangaScraper

struct ExploreTabView: View {
    @State var showManageSource: Bool = false
    @State var searchText: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Favorite Source(s)") {
                    FavoriteSourceSectionView(swipe: false)
                }
                
                Section("Active Source(s)") {
                    ActiveSourceSectionView(swipe: false)
                }
            }
            .toolbar {
                ToolbarItem {
                    Label("Manage Source", systemImage: "globe")
                        .onTapGesture {
                            withAnimation {
                                self.showManageSource.toggle()
                            }
                        }
                }
            }
            .sheet(isPresented: $showManageSource) {
                ManagerSourceView()
            }
            .searchable(text: $searchText)
            .navigationTitle("Explore Source")
        }
    }
}
