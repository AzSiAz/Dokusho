//
//  RefreshableImageView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import SwiftUI
import Nuke


struct ChapterImageView: View {
    @StateObject private var image: FetchImage
    @State var id = UUID()
    
    let url: URL
    let contentMode: ContentMode
    let size: CGSize
    
    init(url: URL?, contentMode: ContentMode, size: CGSize) {
        self.url = url ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
        self.contentMode = contentMode
        self.size = size
        
        let image = FetchImage()
        image.pipeline = ImagePipeline.inMemory
        _image = .init(wrappedValue: image)
    }
    
    init(url: String?, contentMode: ContentMode, size: CGSize) {
        let url = URL(string: url ?? "") ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
        self.init(url: url, contentMode: contentMode, size: size)
    }
    
    var body: some View {
        Group {
            switch image.result {
            case .success(let res):
                    Image(uiImage: res.image)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
            case .failure(let err):
                    VStack {
                        Button(action: { id = UUID() }) {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }

                        Text("Error: \(err.localizedDescription)")
                    }
                    .frame(height: size.height)
            default:
                ProgressView()
                    .scaleEffect(3)
                    .frame(width: size.width, height: size.height)
            }
        }
        .id(id)
        .onAppear { image.priority = .high; image.load(url) }
        .onDisappear { image.priority = .low }
    }
}
