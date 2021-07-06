//
//  ReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import NukeUI

typealias OnProgress = (_ status: MangaChapter.Status) -> Void

enum ReadingDirection: String, CaseIterable {
    case rightToLeft = "Right to Left (Manga)"
    case leftToRight = "Left to Right (Manhua)"
    case vertical = "Vertical (Webtoon, no gaps)"
}

struct ReaderView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var vm: ReaderVM
    @State var direction: ReadingDirection = .vertical
    @State var progress: Double = 1
    @State var showReaderDirectionChoice = false
    
    var body: some View {
        VStack {
            if let links = vm.chapterImages?.map { $0.imageUrl } {
                if direction == .vertical {
                    VerticalReaderView(
                        showToolbar: $vm.showToolBar,
                        sliderProgress: $progress,
                        links: links,
                        onProgress: vm.saveProgress
                    )
                }
                else {
                    HorizontalReaderView(
                        direction: direction,
                        links: links,
                        showToolbar: $vm.showToolBar,
                        sliderProgress: $progress,
                        onProgress: vm.saveProgress
                    )
                }
            }
        }
        .onAppear { self.direction = self.vm.chapter.manga?.type.getDefaultReadingDirection() ?? .vertical }
        .onTapGesture { withAnimation { vm.showToolBar.toggle() } }
        .task { await vm.fetchChapter() }
        .statusBar(hidden: !vm.showToolBar)
        .overlay(alignment: .top) {
            if vm.showToolBar {
                HStack(alignment: .top) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                    Spacer()

                    Text(vm.chapter.title!)

                    Spacer()
                    Button(action: { showReaderDirectionChoice.toggle() }) {
                        Image(systemName: "slider.vertical.3")
                    }
                    .actionSheet(isPresented: $showReaderDirectionChoice) {
                        var actions: [ActionSheet.Button] = ReadingDirection.allCases.map { dir in
                            return .default(Text(dir.rawValue), action: { self.direction = dir })
                        }
                        actions.append(.cancel())
                        
                        return ActionSheet(
                            title: Text("Choose reader direction"),
                            message: Text("Not saved for now"),
                            buttons: actions
                        )
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
