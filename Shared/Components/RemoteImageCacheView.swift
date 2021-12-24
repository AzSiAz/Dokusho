//
//  RemoteImageCacheView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/07/2021.
//

import SwiftUI
import Nuke

struct RemoteImageCacheView: View {
    @StateObject private var image: FetchImage
    
    let url: URL
    let contentMode: ContentMode
    
    init(url: URL?, contentMode: ContentMode) {
        self.url = url ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
        self.contentMode = contentMode
        
        let image = FetchImage()
        image.pipeline = .coverCache
        _image = .init(wrappedValue: image)
    }
    
    init(url: String?, contentMode: ContentMode) {
        let url = URL(string: url ?? "") ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
        self.init(url: url, contentMode: contentMode)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if image.view == nil { ProgressView() }

            image.view?
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .clipped()
        }
        .onAppear { image.load(url) }
        .onChange(of: url) { image.load($0) }
        .onDisappear(perform: image.reset)
    }
}
