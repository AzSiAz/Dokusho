//
//  VerticalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 16/06/2021.
//

import SwiftUI

struct VerticalReaderView: View {
    @ObservedObject var vm: ReaderVM
    
    var body: some View {
        GeometryReader { proxy in
            // TODO: Add a ScrollViewReader to be able to go to specific ID when tabIndex is updated from bottom overlay slider
            ScrollView([.vertical], showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(vm.getImagesOrderForDirection(), id: \.self) { image in
                        RefreshableImageView(url: image.imageUrl, size: CGSize(width: proxy.size.width, height: UIScreen.main.bounds.height))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.isLargeScreen ? proxy.size.width / 2 : proxy.size.width, alignment: .center)
                            .id(image.id)
                            .tag(image)
                            .onAppear { vm.tabIndex = image }
                            .background(Color.black)
                    }
                }
            }
        }
    }
}
