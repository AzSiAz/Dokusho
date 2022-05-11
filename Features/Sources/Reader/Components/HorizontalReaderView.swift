//
//  HorizontalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI

struct HorizontalReaderView: View {
    @ObservedObject var vm: ReaderVM

    var body: some View {
        TabView(selection: $vm.tabIndex) {
            ForEach(vm.getImagesOrderForDirection(), id: \.self) { image in
                GeometryReader { proxy in
                    ChapterImage(url: image.imageUrl)
                        .frame(
                            minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2: proxy.size.width,
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
}
