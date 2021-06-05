//
//  ExploreDetailView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 05/06/2021.
//

import SwiftUI
import MangaSource


struct ExploreDetailView: View {
    @EnvironmentObject var sourcesSvc: MangaSourceService

    @State var fetchType: SourceFetchType
    @State var srcId: Int
    
    var body: some View {
        Text(fetchType.rawValue)
    }
}

struct ExploreDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreDetailView(fetchType: .latest, srcId: 1)
    }
}
