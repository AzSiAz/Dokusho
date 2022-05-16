//
//  ReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import DataKit

typealias OnProgress = (_ status: ChapterStatus) -> Void

public struct OldReaderView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var vm: ReaderVM
    @ObservedObject public var readerManager: ReaderManager
    
    public init(vm: ReaderVM, readerManager: ReaderManager) {
        _vm = .init(wrappedValue: vm)
        _readerManager = .init(wrappedValue: readerManager)
    }
    
    public var body: some View {
        Group {
            if (vm.images.isEmpty && !vm.isLoading) {
                Text("No images found in this chapter")
            }
            else {
                if vm.direction == .vertical { VerticalReaderView(vm: vm) }
                else { HorizontalReaderView(vm: vm) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .onTapGesture { vm.toggleToolbar() }
        .task { await vm.fetchChapter() }
        .statusBar(hidden: !vm.showToolBar)
        .overlay(alignment: .bottom) { ShowPageCount() }
        .overlay(alignment: .top) { TopOverlay() }
        .overlay(alignment: .bottom) { BottomOverlay() }
        .onChange(of: vm.tabIndex) { vm.updateChapterStatus(image: $0) }
        .onChange(of: vm.chapter) { _ in Task { await vm.fetchChapter() } }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    func ShowPageCount() -> some View {
        if !vm.showToolBar {
            if vm.images.isEmpty {
                Text("Loading...")
            } else {
                Text("\(Int(vm.progressBarCurrent())) / \(vm.images.count)")
                    .transition(.move(edge: !vm.showToolBar ? .bottom : .top))
                    .glowBorder(color: .black, lineWidth: 3)
            }
        }
    }
    
    @ViewBuilder
    func BottomOverlay() -> some View {
        if vm.showToolBar {
            HStack {
                Button(action: { vm.goToChapter(.previous) }) {
                    Image(systemName: "chevron.left")
                        .padding(.trailing)
                }
                .disabled(!vm.hasPreviousChapter())

                Spacer()

                HStack {
                    if vm.images.isEmpty {
                        EmptyView()
                    } else {
                        // TODO: Add a custom slider to be able to update tabIndex value
                        ProgressView(value: vm.progressBarCurrent(), total: Double(vm.images.count))
                        Text("\(Int(vm.progressBarCurrent())) / \(vm.images.count)")
                            .padding(.leading)
                    }
                }
                .frame(height: 25)

                Spacer()
                
                Button(action: { vm.goToChapter(.next) }) {
                    Image(systemName: "chevron.right")
                        .padding(.leading)
                }
                .disabled(!vm.hasNextChapter())
            }
            .padding(.all)
            .background(.thickMaterial)
            .offset(x: 0, y: vm.showToolBar ? 0 : 500)
            .transition(.move(edge: vm.showToolBar ? .bottom : .top))
        }
    }
    
    @ViewBuilder
    func TopOverlay() -> some View {
        if vm.showToolBar {
            HStack(alignment: .center) {
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "xmark")
                }

                Spacer()
                
                Text(vm.chapter.title)
                    .foregroundColor(.primary)
                
                Spacer()
                Button(action: { vm.showReaderDirectionChoice.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                }
                .actionSheet(isPresented: $vm.showReaderDirectionChoice) {
                    var actions: [ActionSheet.Button] = ReadingDirection.allCases.map { dir in
                        return .default(Text(dir.rawValue), action: { self.vm.direction = dir })
                    }
                    actions.append(.cancel())
                    
                    return ActionSheet(
                        title: Text("Choose reader direction"),
                        message: Text("Not saved for now"),
                        buttons: actions
                    )
                }
            }
            .padding(.all)
            .offset(x: 0, y: vm.showToolBar ? 0 : -150)
            .background(.thickMaterial)
            .transition(.move(edge: vm.showToolBar ? .top : .bottom))
        }
    }
}
