//
//  HorizontalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import Common

struct HorizontalReaderView: View {
    @Bindable var vm: ReaderVM
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State var isZooming = false

    /// On regular width (iPad) we show two pages per screen, like a real book.
    private var isDoublePage: Bool { horizontalSizeClass == .regular }

    struct Spread: Identifiable, Hashable {
        var links: [ReaderLink]
        var id: ReaderLink { links.first ?? .image(url: "") }
    }

    /// Groups the ordered links into spreads: consecutive image pages are paired
    /// (when double-page), while chapter-boundary links always stand alone.
    private var spreads: [Spread] {
        let links = vm.getImagesOrderForDirection()
        guard isDoublePage else { return links.map { Spread(links: [$0]) } }

        var result: [Spread] = []
        var pending: [ReaderLink] = []

        func flush() {
            var i = 0
            while i < pending.count {
                if i + 1 < pending.count {
                    result.append(Spread(links: [pending[i], pending[i + 1]]))
                    i += 2
                } else {
                    result.append(Spread(links: [pending[i]]))
                    i += 1
                }
            }
            pending.removeAll()
        }

        for link in links {
            if case .image = link {
                pending.append(link)
            } else {
                flush()
                result.append(Spread(links: [link]))
            }
        }
        flush()
        return result
    }

    /// Maps the current page (`vm.tabIndex`) to the spread that contains it, so
    /// the TabView selection is always a valid spread tag regardless of reading
    /// direction or which page of a pair the index points at. Selecting a spread
    /// writes back its first page as the current index.
    private var spreadSelection: Binding<ReaderLink> {
        Binding(
            get: {
                let current = vm.tabIndex
                return spreads.first(where: { $0.links.contains(current) })?.id
                    ?? spreads.first?.id
                    ?? current
            },
            set: { vm.tabIndex = $0 }
        )
    }

    var body: some View {
        TabView(selection: spreadSelection) {
            ForEach(spreads) { spread in
                GeometryReader { proxy in
                    SpreadView(spread: spread, proxy: proxy)
                }
                .id(spread.id)
                .tag(spread.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .id(vm.images)
        .onAppear { vm.isDoublePage = isDoublePage }
        .onChange(of: isDoublePage) { _, newValue in vm.isDoublePage = newValue }
        .onChange(of: vm.tabIndex) { _, _ in
            Task { await vm.checkAndTriggerChapterTransition() }
        }
    }

    @ViewBuilder
    func SpreadView(spread: Spread, proxy: GeometryProxy) -> some View {
        // A single chapter-boundary card fills the whole screen; image pages are
        // laid out side by side. getImagesOrderForDirection already reversed the
        // sequence for right-to-left, so HStack order is correct as-is.
        if spread.links.count <= 1 {
            ReaderLinkRender(image: spread.links.first ?? .image(url: ""),
                             proxy: proxy,
                             width: proxy.size.width)
        } else {
            HStack(spacing: 0) {
                ForEach(spread.links, id: \.self) { link in
                    ReaderLinkRender(image: link, proxy: proxy, width: proxy.size.width / 2)
                }
            }
        }
    }

    @ViewBuilder
    func ReaderLinkRender(image: ReaderLink, proxy: GeometryProxy, width: CGFloat) -> some View {
        Group {
            switch image {
            case .image(let url):
                ChapterImageView(url: url, contentMode: .fit, isZooming: $isZooming)
                    .frame(minWidth: width, minHeight: proxy.size.height, alignment: .center)
            case .previous(let chapter):
                if vm.hasPreviousChapter() {
                    ChapterBoundaryView(
                        boundaryType: .previous(chapter: chapter),
                        isLoading: vm.isTransitioningChapter,
                        error: vm.transitionError,
                        onRetry: { vm.retryTransition(.previous) }
                    )
                    .frame(minWidth: width, minHeight: proxy.size.height, alignment: .center)
                } else {
                    ChapterBoundaryView(boundaryType: .startOfBook)
                        .frame(minWidth: width, minHeight: proxy.size.height, alignment: .center)
                }
            case .next(let chapter):
                if vm.hasNextChapter() {
                    ChapterBoundaryView(
                        boundaryType: .next(chapter: chapter),
                        isLoading: vm.isTransitioningChapter,
                        error: vm.transitionError,
                        onRetry: { vm.retryTransition(.next) }
                    )
                    .frame(minWidth: width, minHeight: proxy.size.height, alignment: .center)
                } else {
                    ChapterBoundaryView(boundaryType: .endOfBook)
                        .frame(minWidth: width, minHeight: proxy.size.height, alignment: .center)
                }
            }
        }
        .id(image)
    }
}
