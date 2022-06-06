//
//  RefreshableImageView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import SwiftUI
import Nuke
import Common

struct ChapterImageView: View {
    private let fullHeight = UIScreen.main.bounds.height
    
    @StateObject private var image: FetchImage
    @State var id = UUID()
    
    let url: URL
    let contentMode: ContentMode
    
    init(url: URL?, contentMode: ContentMode) {
        self.url = url ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
        self.contentMode = contentMode
        
        let image = FetchImage()
        image.pipeline = ImagePipeline.inMemory
        _image = .init(wrappedValue: image)
    }
    
    init(url: String?, contentMode: ContentMode) {
        let url = URL(string: url ?? "") ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
        self.init(url: url, contentMode: contentMode)
    }
    
    var body: some View {
        Group {
            switch image.result {
            case .success(let res):
                    Image(uiImage: res.image)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .addPinchAndPan()
                        .contextMenu { ContextMenu(image: res.image) }
            case .failure(let err):
                    VStack {
                        Button(action: { id = UUID() }) {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }

                        Text("Error: \(err.localizedDescription)")
                    }
                    .frame(height: fullHeight)
            default:
                ProgressView()
                    .scaleEffect(3)
                    .frame(height: fullHeight)
            }
        }
        .id(id)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }
    
    @ViewBuilder
    func ContextMenu(image: UIImage) -> some View {
        Button(action: { saveImage(image: image) }) {
            Label("Save to library", systemImage: "icloud.and.arrow.down")
        }
    }
    
    func onAppear() {
        image.priority = .high
        image.load(url)
    }
    
    func onDisappear() {
        image.priority = .low
    }
    
    func saveImage(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
