//
//  HorizontalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import Common

struct HorizontalReaderView: View {
    @Bindable var vm: ReaderViewModel
    @State var isZooming = false

    var body: some View {
        TabView(selection: $vm.tabIndex) {
            ForEach(vm.getImagesOrderForDirection(), id: \.self) { image in
                GeometryReader { proxy in
                    ReaderLinkRender(image: image, proxy: proxy)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .id(vm.images)
    }
    
    @ViewBuilder
    func ReaderLinkRender(image: ReaderLink, proxy: GeometryProxy) -> some View {
        Group {
            switch image {
            case .image(let url):
                ImageView(image: url, proxy: proxy)
            case .previous(let chapter):
                DirectionView(title: "Previous chapter \(chapter.title)", direction: .previous, proxy: proxy)
            case .next(let chapter):
                DirectionView(title: "Next chapter \(chapter.title)", direction: .next, proxy: proxy)
            }
        }
        .id(image)
        .tag(image)
    }
    
    func ImageView(image: String, proxy: GeometryProxy) -> some View {
        ChapterImageView(url: image, contentMode: .fit, isZooming: $isZooming)
            .frame(
                minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                minHeight: proxy.size.height,
                alignment: .center
            )
    }
    
    func DirectionView(title: String, direction: GoToChapterDirection, proxy: GeometryProxy) -> some View {
        Rectangle()
            .fill(.black)
            .frame(
                minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                minHeight: proxy.size.height,
                alignment: .center
            )
            .overlay(alignment: .center) {
                Text(title)
            }
            .onTapGesture(count: 3) { vm.goToChapter(direction) }
    }
}
