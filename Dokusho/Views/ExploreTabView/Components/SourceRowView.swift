//
//  SourceRowView.swift
//  SourceRowView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI

struct SourceRowView: View {
    @ObservedObject var source: SourceEntity
    
    var body: some View {
        HStack {
            RemoteImageCacheView(url: source.icon, contentMode: .fit)
                .frame(width: 32, height: 32)
                .padding(.trailing)
            
            VStack(alignment: .leading) {
                Text(source.name ?? "")
                Text(source.language ?? "")
            }
            .padding(.leading, 8)
        }
        .padding(.vertical)
    }
}
