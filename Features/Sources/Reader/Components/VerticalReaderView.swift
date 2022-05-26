//
//  VerticalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 16/06/2021.
//

import SwiftUI
import Common
import MangaScraper

struct VerticalReaderView: View {
    @ObservedObject var vm: ReaderVM
    
    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView([.vertical], showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.getImagesOrderForDirection(), id: \.self) { image in
                            ChapterImageView(url: image, contentMode: .fit)
                                .frame(
                                    width: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                                    alignment: .center
                                )
                                .id(image)
                                .tag(image)
                                .onAppear { vm.tabIndex = image }
                        }
                    }
                }
            }
        }
    }
}
