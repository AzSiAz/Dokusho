//
//  HorizontalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import Common
import SwiftUIPager

struct HorizontalReaderView: View {
    @ObservedObject var vm: ReaderVM
    @Preference(\.useNewHorizontalReader) var userNewHorizontalReader
    @StateObject var page: Page = .first()
    @State var isZooming = false
    
    var body: some View {
        if vm.images.isEmpty || vm.isLoading {
            ProgressView()
                .scaleEffect(3)
        } else {
            if userNewHorizontalReader { NewReader() }
            else { OldReader() }
        }
    }
    
    @ViewBuilder
    func OldReader() -> some View {
        TabView(selection: $vm.tabIndex) {
            ForEach(vm.getImagesOrderForDirection()) { image in
                GeometryReader { proxy in
                    ChapterImageView(url: image, contentMode: .fit)
                        .frame(
                            minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                            minHeight: proxy.size.height,
                            alignment: .center
                        )
                        .id(image)
                        .tag(image)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    @ViewBuilder
    func NewReader() -> some View {
        Pager(page: page, data: vm.images, id: \.id) { image in
            GeometryReader { proxy in
                ChapterImageView(url: image, contentMode: .fit)
                    .frame(
                        minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width,
                        minHeight: proxy.size.height,
                        alignment: .center
                    )
                    .addPinchAndPan(isZooming: $isZooming)
                    .id(image)
                    .tag(image)
            }
        }
        .draggingAnimation(.steep(duration: 0.75))
        .horizontal(vm.getHorizontalDirection())
        .pagingPriority(.simultaneous)
        .allowsDragging(!isZooming)
        .onChange(of: page.index) { index in
            vm.tabIndex = vm.images[index]
        }
    }
}
