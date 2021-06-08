//
//  ExploreView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI
import MangaSource

struct ExploreView: View {
    let sourcesSvc: MangaSourceService = MangaSourceService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(sourcesSvc.getSourceList()) { src in
                    SourceRow(source: src)
                        .padding()
                }
            }
            .navigationTitle("Explore")
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
