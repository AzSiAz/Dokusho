//
//  ReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import DataKit
import Common

typealias OnProgress = (_ status: ChapterStatus) -> Void

public struct ReaderView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var vm: ReaderVM
    @ObservedObject public var readerManager: ReaderManager
    @Namespace private var overlayAnimation
    
    public init(vm: ReaderVM, readerManager: ReaderManager) {
        _vm = .init(wrappedValue: vm)
        _readerManager = .init(wrappedValue: readerManager)
    }
    
    public var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .scaleEffect(3)
            } else {
                if vm.direction == .vertical { VerticalReaderView(vm: vm) }
                else { HorizontalReaderView(vm: vm) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .onTapGesture { vm.toggleToolbar() }
        .task(id: vm.currentChapter) { await vm.fetchChapter() }
        .task(id: vm.tabIndex) { await vm.updateChapterStatus() }
        .statusBar(hidden: !vm.showToolBar)
        .overlay(alignment: .top) { TopOverlay() }
        .overlay(alignment: .bottom) { BottomOverlay() }
        .preferredColorScheme(.dark)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            vm.cancelTasks()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            vm.cancelTasks()
        }
        .task(id: vm.tabIndex) {
            await vm.backgroundFetchImage()
        }
    }
    
    @ViewBuilder
    func BottomOverlay() -> some View {
        if vm.showToolBar {
            VStack(alignment: .center, spacing: 1) {
                HStack(alignment: .center) {
                    Button(action: { vm.goToChapter(.previous) }) {
                        Image(systemName: "chevron.left")
                            .padding(.trailing)
                    }
                    .disabled(!vm.hasPreviousChapter())

                    Spacer()

                    if !vm.images.isEmpty {
                        VStack {
                            // TODO: Add a custom slider to be able to update tabIndex value
                            ProgressView(value: vm.progressBarCurrent(), total: vm.progressBarCount())
                                .rotationEffect(.degrees(vm.direction == .rightToLeft ? 180 : 0))
                        }
                        .frame(height: 25)
                    }

                    Spacer()
                    
                    Button(action: { vm.goToChapter(.next) }) {
                        Image(systemName: "chevron.right")
                            .padding(.leading)
                    }
                    .disabled(!vm.hasNextChapter())
                }
                
                if !vm.images.isEmpty {
                    Text("\(Int(vm.progressBarCurrent())) of \(Int(vm.progressBarCount()))")
                        .padding(.leading)
                        .font(.footnote.italic())
                }
            }
            .padding([.horizontal, .top])
            .background(.thickMaterial)
            .offset(x: 0, y: vm.showToolBar ? 0 : 500)
            .transition(.move(edge: vm.showToolBar ? .bottom : .top))
        } else {
            if !vm.images.isEmpty {
                Text("\(Int(vm.progressBarCurrent())) / \(Int(vm.progressBarCount()))")
                    .transition(.move(edge: !vm.showToolBar ? .bottom : .top))
                    .glowBorder(color: .black, lineWidth: 3)
                    .font(.footnote.italic())
            }
        }
    }
    
    @ViewBuilder
    func TopOverlay() -> some View {
        if vm.showToolBar {
            Group {
                HStack(alignment: .center) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 0) {
                        Text(vm.manga.title)
                            .font(.subheadline)
                            .allowsTightening(true)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                        Text(vm.currentChapter.title)
                            .font(.subheadline)
                            .italic()
                            .allowsTightening(true)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Menu("Chapters") {
                            ForEach(vm.getChapters()) { chapter in
                                Button(action: { vm.goToChapter(to: chapter) }) {
                                    SelectedMenuItem(text: chapter.title, comparaison: vm.currentChapter == chapter)
                                }
                            }
                        }
                        
                        Menu("Reader direction") {
                            ForEach(ReadingDirection.allCases, id: \.self) { direction in
                                Button(action: { vm.setReadingDirection(new: direction) }) {
                                    SelectedMenuItem(text: direction.rawValue, comparaison: vm.direction == direction)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .padding(.all)
            .offset(x: 0, y: vm.showToolBar ? 0 : -150)
            .background(.thickMaterial)
            .transition(.move(edge: vm.showToolBar ? .top : .bottom))
        }
    }
    
    @ViewBuilder
    func SelectedMenuItem(text: String, comparaison: Bool, systemImage: String = "checkmark") -> some View {
        if comparaison && !systemImage.isEmpty { Label(text, systemImage: systemImage) }
        else { Text(text) }
    }
}
