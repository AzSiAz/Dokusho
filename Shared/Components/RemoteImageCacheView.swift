//
//  RemoteImageCacheView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/07/2021.
//

import SwiftUI
import Nuke

struct RemoteImageCacheView: View {
    let url: URL
    let contentMode: ContentMode
    
    @StateObject private var image = FetchImage()
    
    var body: some View {
        ZStack {
            if image.view == nil {
                ProgressView()
            }

            image.view?
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .clipped()
        }
        .id(UUID())
        .onAppear { image.load(url) }
        .onChange(of: url) { image.load($0) }
        .onDisappear(perform: image.reset)
    }
}
