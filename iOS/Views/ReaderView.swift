//
//  ReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import Pages
import NukeUI

struct ReaderView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm: ReaderVM
    
    var body: some View {
        VStack {
            if vm.showToolBar {
                VStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            
            if let images = vm.chapterImages {
                if vm.manga.type == .manga {
                    HorizontalReaderView(direction: .rightToLeft, links: images.map { $0.imageUrl })
                }
                else if vm.manga.type == .manhua {
                    HorizontalReaderView(direction: .leftToRight, links: images.map { $0.imageUrl })
                }
                else {
                    HorizontalReaderView(direction: .rightToLeft, links: images.map { $0.imageUrl })
                }
            }
        }
        .onTapGesture { vm.showToolBar.toggle() }
        .task { await vm.fetchChapter() }
    }
}

//struct ReaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReaderView(vm: ReaderVM(for: SourceChapter, in: <#T##SourceManga#>, with: <#T##Source#>))
//    }
//}
