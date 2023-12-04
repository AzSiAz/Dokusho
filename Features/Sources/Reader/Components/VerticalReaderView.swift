//
//  VerticalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 16/06/2021.
//

import SwiftUI
import Common

struct VerticalReaderView: View {
    @Bindable var vm: ReaderViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView([.vertical], showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.getImagesOrderForDirection(), id: \.self) { image in
                            ReaderLinkRender(image: image, proxy: proxy)
                        }
                    }
                }
                .id(vm.images)
            }
        }
    }
    
    @ViewBuilder
    func ReaderLinkRender(image: ReaderLink, proxy: GeometryProxy) -> some View {
        Group {
            switch image {
            case .image(let url):
                ImageView(image: url, proxy: proxy)
            case .previous(let chapter):
                DirectionView(title: "Previous chapter \(chapter.title)", direction: .previous, size: .init(width: proxy.size.width, height: 50))
            case .next(let chapter):
                DirectionView(title: "Next chapter \(chapter.title)", direction: .next, size: .init(width: proxy.size.width, height: 50))
            }
        }
        .id(image)
        .tag(image)
        .onAppear { vm.updateTabIndex(image: image) }
    }

    func ImageView(image: URL?, proxy: GeometryProxy) -> some View {
        ChapterImageView(url: image, contentMode: .fit, isZooming: .constant(false))
            .frame(
                width: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                alignment: .center
            )
    }
    
    func DirectionView(title: String, direction: GoToChapterDirection, size: CGSize) -> some View {
        Rectangle()
            .fill(.black)
            .frame(
                minWidth: UIScreen.isLargeScreen ? size.width / 2 : size.width,
                minHeight: size.height,
                alignment: .center
            )
            .overlay(alignment: .center) {
                Text(title)
            }
            .onTapGesture(count: 3) { vm.goToChapter(direction) }
    }
}
