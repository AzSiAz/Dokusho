//
//  ReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI

typealias OnProgress = (_ status: ChapterStatus) -> Void

struct ReaderView: View {
    @Environment(\.safeAreaInsets) var inset
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: ReaderVM
    
    var body: some View {
        Group {
            if vm.direction == .vertical { VerticalReaderView(vm: vm) }
            else { HorizontalReaderView(vm: vm) }
        }
        .background(Color.black)
        .navigationBarHidden(true)
        .onTapGesture { withAnimation { vm.showToolBar.toggle() } }
        .task { await vm.fetchChapter() }
        .statusBar(hidden: !vm.showToolBar)
        .overlay(alignment: .top) { TopOverlayView(vm: vm, inset: inset.top, dismiss: dismiss.callAsFunction) }
        .overlay(alignment: .bottom) { BottomOverlayView(vm: vm, inset: inset.bottom) }
        .onChange(of: vm.tabIndex, perform: { image in
            vm.updateChapterStatus(image: image)
        })
        .preferredColorScheme(.dark)
        .edgesIgnoringSafeArea([.bottom, .top])
    }
}
