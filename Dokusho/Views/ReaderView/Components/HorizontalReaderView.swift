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
                    RefreshableImageView(url: image.imageUrl, size: proxy.size)
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            minWidth: UIScreen.isLargeScreen ? proxy.size.width / 2: proxy.size.width,
                            minHeight: proxy.size.height,
                            alignment: .center
                        )
                        .background(Color.black)
                        .tag(image)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.black)
    }
}
