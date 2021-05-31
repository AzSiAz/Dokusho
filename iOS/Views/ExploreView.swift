//
//  ExploreView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var sourcesSvc: MangaSourceService
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(sourcesSvc.getSourceList()) { src in
                    HStack {
                        Text(src.name)
                    }
                }
            }
        }
        .navigationTitle("Explore")
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
