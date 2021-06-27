//
//  ReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import Pages
import NukeUI

typealias OnProgress = (_ status: MangaChapter.Status) -> Void

struct ReaderView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: ReaderVM
    @State var progress: Double = 0
    
    var body: some View {
        VStack {
            if let links = vm.chapterImages?.map { $0.imageUrl } {
                if vm.chapter.manga?.type == .manga {
                    HorizontalReaderView(
                        direction: .rightToLeft,
                        links: links,
                        showToolbar: $vm.showToolBar,
                        sliderProgress: $progress,
                        onProgress: vm.saveProgress
                    )
                }
                else if vm.chapter.manga?.type == .manhua {
                    HorizontalReaderView(
                        direction: .leftToRight,
                        links: links,
                        showToolbar: $vm.showToolBar,
                        sliderProgress: $progress,
                        onProgress: vm.saveProgress
                    )
                }
                else {
                    VerticalReaderView(
                        showToolbar: $vm.showToolBar,
                        sliderProgress: $progress,
                        links: links,
                        onProgress: vm.saveProgress
                    )
                }
            }
        }
        .onTapGesture { vm.showToolBar.toggle() }
        .task { await vm.fetchChapter() }
        .overlay(alignment: .top) {
            if vm.showToolBar {
                HStack(alignment: .top) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "slider.vertical.3")
                    }
                }
                .frame(height: 50, alignment: .center)
                .padding(.horizontal)
                .background(Color.black)
            }
        }
        .overlay(alignment: .bottom) {
            if vm.showToolBar {
                HStack(alignment: .top) {
                    ProgressView(value: progress, total: Double(vm.chapterImages?.count ?? 0))
                }
                .frame(height: 50, alignment: .center)
                .padding(.horizontal)
                .background(Color.black)
            }
        }
    }
}
