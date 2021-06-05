//
//  ExploreView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI
import MangaSource

struct ExploreView: View {
    @EnvironmentObject var sourcesSvc: MangaSourceService
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(sourcesSvc.getSourceList()) { src in
                    SourceRow(source: src)
                        .padding()
                }
            }
            .fixFlickering()
            .navigationTitle("Explore")
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
