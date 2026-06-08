//
//  HorizontalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import Common

struct HorizontalReaderView: View {
    @ObservedObject var vm: ReaderVM
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
        .onChange(of: vm.tabIndex) { _, _ in
            Task { await vm.checkAndTriggerChapterTransition() }
        }
    }

    @ViewBuilder
    func ReaderLinkRender(image: ReaderLink, proxy: GeometryProxy) -> some View {
        Group {
            switch image {
            case .image(let url):
                ImageView(image: url, proxy: proxy)
            case .previous(let chapter):
                if vm.hasPreviousChapter() {
                    ChapterBoundaryView(
                        boundaryType: .previous(chapter: chapter),
                        isLoading: vm.isTransitioningChapter,
                        error: vm.transitionError,
                        onRetry: { vm.retryTransition(.previous) }
                    )
                    .frame(
                        minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                        minHeight: proxy.size.height,
                        alignment: .center
                    )
                } else {
                    ChapterBoundaryView(
                        boundaryType: .startOfBook,
                        isLoading: false,
                        error: nil,
                        onRetry: nil
                    )
                    .frame(
                        minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                        minHeight: proxy.size.height,
                        alignment: .center
                    )
                }
            case .next(let chapter):
                if vm.hasNextChapter() {
                    ChapterBoundaryView(
                        boundaryType: .next(chapter: chapter),
                        isLoading: vm.isTransitioningChapter,
                        error: vm.transitionError,
                        onRetry: { vm.retryTransition(.next) }
                    )
                    .frame(
                        minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                        minHeight: proxy.size.height,
                        alignment: .center
                    )
                } else {
                    ChapterBoundaryView(
                        boundaryType: .endOfBook,
                        isLoading: false,
                        error: nil,
                        onRetry: nil
                    )
                    .frame(
                        minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                        minHeight: proxy.size.height,
                        alignment: .center
                    )
                }
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
}
