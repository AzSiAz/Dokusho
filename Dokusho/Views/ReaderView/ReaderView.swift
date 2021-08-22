//
//  ReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI

typealias OnProgress = (_ status: ChapterStatus) -> Void

enum ReadingDirection: String, CaseIterable {
    case rightToLeft = "Right to Left (Manga)"
    case leftToRight = "Left to Right (Manhua)"
    case vertical = "Vertical (Webtoon, no gaps)"
}

struct ReaderView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: ReaderVM
    
    var body: some View {
        Group {
            if !vm.images.isEmpty {
                if vm.direction == .vertical { VerticalReaderView(vm: vm) }
                else { HorizontalReaderView(vm: vm) }
            }
        }
        .background(Color.black)
        .navigationBarHidden(true)
        .onTapGesture { withAnimation { vm.showToolBar.toggle() } }
        .task { await vm.fetchChapter() }
        .statusBar(hidden: !vm.showToolBar)
        .overlay(alignment: .top) { TopOverlayView(vm: vm, dismiss: dismiss.callAsFunction) }
        .overlay(alignment: .bottom) { BottomOverlayView(vm: vm) }
        .onChange(of: vm.tabIndex, perform: { image in
            vm.updateChapterStatus(image: image)
        })
    }
}
