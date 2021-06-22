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
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm: ReaderVM
    
    var body: some View {
        VStack {
            if vm.showToolBar {
                VStack {
                    Button(action: {
                        async {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            
            if let links = vm.chapterImages?.map { $0.imageUrl } {
                if vm.chapter.manga?.type == .manga {
                    HorizontalReaderView(
                        direction: .rightToLeft,
                        links: links,
                        showToolbar: $vm.showToolBar,
                        onProgress: vm.saveProgress
                    )
                }
                else if vm.chapter.manga?.type == .manhua {
                    HorizontalReaderView(
                        direction: .leftToRight,
                        links: links,
                        showToolbar: $vm.showToolBar,
                        onProgress: vm.saveProgress
                    )
                }
                else {
                    VerticalReaderView(
                        showToolbar: $vm.showToolBar,
                        links: links,
                        onProgress: vm.saveProgress
                    )
                }
            }
        }
        .onTapGesture { vm.showToolBar.toggle() }
        .task { await vm.fetchChapter() }
    }
}
