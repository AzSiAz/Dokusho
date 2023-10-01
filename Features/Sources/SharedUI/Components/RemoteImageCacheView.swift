//
//  RemoteImageCacheView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/07/2021.
//

import SwiftUI
import Nuke
import NukeUI
import Common

public struct RemoteImageCacheView: View {
    let url: URL
    let contentMode: ContentMode
    let pipeline: ImagePipeline
    
    public init(
        url: String?,
        contentMode: ContentMode,
        pipeline: ImagePipeline = .coverCache)
    {
        self.url = URL(string: url ?? "https://picsum.photos/seed/picsum/200/300")!
        self.contentMode = contentMode
        self.pipeline = pipeline
    }

    public var body: some View {
        GeometryReader { proxy in
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: self.contentMode)
                } else if state.isLoading {
                    Color
                        .gray
                        .border(.gray)
                }
            }
            .processors([.resize(size: proxy.size)])
            .pipeline(pipeline)
            .id(url)
        }
    }
}
