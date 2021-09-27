//
//  SourceRowView.swift
//  SourceRowView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI
import MangaScraper

struct SourceRowView: View {
    let src: Source
    
    init(source: SourceEntity) {
        self.src = MangaScraperService.shared.getSource(sourceId: source.sourceId)!
    }
    
    var body: some View {
        HStack {
            RemoteImageCacheView(url: src.icon, contentMode: .fit)
                .frame(width: 32, height: 32)
                .padding(.trailing)
            
            VStack(alignment: .leading) {
                Text(src.name)
                Text(src.lang.rawValue)
            }
            .padding(.leading, 8)
        }
        .padding(.vertical)
    }
}
