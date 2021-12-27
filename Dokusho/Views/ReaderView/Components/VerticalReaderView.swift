//
//  VerticalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 16/06/2021.
//

import SwiftUI

struct VerticalReaderView: View {
    @Environment(\.safeAreaInsets) var inset
    @ObservedObject var vm: ReaderVM
    
    var body: some View {
        GeometryReader { proxy in
            let imgSize = CGSize(width: proxy.size.width, height: UIScreen.main.bounds.height)

            // TODO: Add a ScrollViewReader to be able to go to specific ID when tabIndex is updated from bottom overlay slider
            ScrollView([.vertical], showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(vm.getImagesOrderForDirection(), id: \.self) { image in
                        ChapterImageView(url: image.imageUrl, contentMode: .fit, size: imgSize)
                            .frame(
                                width: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                                alignment: .center
                            )
                            .id(image)
                            .tag(image)
                            .onAppear { vm.tabIndex = image }
                            .addPinchZoom()
                    }
                }
            }
        }
    }
}
