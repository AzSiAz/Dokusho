//
//  RemoteImageCacheView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/07/2021.
//

import SwiftUI
import Nuke
import NukeUI

public struct RemoteImageCacheView: View {
    let url: String
    let contentMode: ImageResizingMode
    let pipeline: ImagePipeline
    
    public init(url: String?, contentMode: ImageResizingMode, pipeline: ImagePipeline = .coverCache) {
        self.url = url ?? "https://picsum.photos/seed/picsum/200/300"
        self.contentMode = contentMode
        self.pipeline = pipeline
    }
    
//    ImageProcessors.RoundedCorners(radius: radius, border: .init(color: .gray, width: 0.2))
    public var body: some View {
        GeometryReader { proxy in
            LazyImage(request: url.asImageRequest(), resizingMode: contentMode)
                .processors([ImageProcessors.Resize(size: proxy.size)])
                .pipeline(pipeline)
                .id(url)
        }
    }
}
