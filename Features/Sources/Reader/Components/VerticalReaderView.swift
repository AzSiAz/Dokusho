//
//  VerticalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 16/06/2021.
//

import SwiftUI
import Common

struct VerticalReaderView: View {
    @ObservedObject var vm: ReaderVM

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
                if vm.hasPreviousChapter() {
                    ChapterBoundaryView(
                        boundaryType: .previous(chapter: chapter),
                        isLoading: vm.isTransitioningChapter,
                        error: vm.transitionError,
                        onRetry: { vm.retryTransition(.previous) }
                    )
                    .frame(
                        width: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                        height: proxy.size.height * 0.4,
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
                        width: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                        height: proxy.size.height * 0.3,
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
                        width: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                        height: proxy.size.height * 0.4,
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
                        width: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                        height: proxy.size.height * 0.3,
                        alignment: .center
                    )
                }
            }
        }
        .id(image)
        .tag(image)
        .onAppear {
            vm.updateTabIndex(image: image)
            // Trigger auto-transition when boundary view appears
            if case .next = image {
                Task { await vm.checkAndTriggerChapterTransition() }
            } else if case .previous = image {
                Task { await vm.checkAndTriggerChapterTransition() }
            }
        }
    }

    func ImageView(image: String, proxy: GeometryProxy) -> some View {
        ChapterImageView(url: image, contentMode: .fit, isZooming: .constant(false))
            .frame(
                width: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                alignment: .center
            )
    }
}
