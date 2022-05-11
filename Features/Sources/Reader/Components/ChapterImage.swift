//
//  ChapterImage.swift
//  Dokusho
//
//  Created by Stef on 02/10/2021.
//

import SwiftUI
import NukeUI
import Nuke

struct ChapterImage: View {
    private let fullHeight = UIScreen.main.bounds.height
    let url: String
    
    @State var id = UUID()
    
    var body: some View {
            LazyImage(source: url) { state in
                if let image = state.imageContainer?.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .addPinchAndPan()
                        .contextMenu {
                            Button(action: { saveImage(image: image) }) {
                                Label("Save to library", systemImage: "icloud.and.arrow.down")
                            }
                        }
                } else if let error = state.error {
                    VStack {
                        Button(action: { id = UUID() }) {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }

                        Text("Error: \(error.localizedDescription)")
                    }
                    .frame(height: fullHeight)
                } else {
                    ProgressView(value: Double(state.progress.completed), total: Double(state.progress.total))
                        .progressViewStyle(.circular)
                        .frame(height: fullHeight)
                }
            }
            .onDisappear(.none)
            .pipeline(.inMemory)
//            .id(id)
    }
    
    func saveImage(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
