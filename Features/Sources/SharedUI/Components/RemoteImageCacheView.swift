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
    let radius: Double
    
    public init(url: String?, contentMode: ImageResizingMode, radius: Double = 10, pipeline: ImagePipeline = .coverCache) {
        self.url = url ?? "https://picsum.photos/seed/picsum/200/300"
        self.contentMode = contentMode
        self.pipeline = pipeline
        self.radius = radius
    }
    
    public var body: some View {
        GeometryReader { proxy in
            LazyImage(source: url, resizingMode: contentMode)
                .processors([ImageProcessors.Resize(size: proxy.size), ImageProcessors.RoundedCorners(radius: radius)])
                .pipeline(pipeline)
                .cornerRadius(radius)
                .id(url)
        }
    }
}
