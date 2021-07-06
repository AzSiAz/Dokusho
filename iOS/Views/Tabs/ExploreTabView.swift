//
//  ExploreView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI

struct ExploreTabView: View {
    @EnvironmentObject var sourcesSvc: MangaSourceService
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sourcesSvc.list, id: \.id) { src in
                    NavigationLink(destination: ExploreSourceView(vm: ExploreSourceVM(for: src))) {
                        SourceRow(source: src)
                            .padding(.vertical)
                    }
                }
            }
            .searchable(text: $sourcesSvc.searchInSource)
            .onSubmit(of: .search) {
                async {
                    await sourcesSvc.search()
                }
            }
            .navigationTitle("Explore")
        }
        .navigationViewStyle(.stack)
    }
}

struct ExploreTabView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabView()
    }
}
