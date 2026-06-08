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
    
    @State private var vm: ReaderVM
    var readerManager: ReaderManager
    @Namespace private var overlayAnimation

    public init(vm: ReaderVM, readerManager: ReaderManager) {
        self.readerManager = readerManager
        self.vm = vm
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
        .toolbarVisibility(vm.showToolBar ? .visible : .hidden, for: .statusBar)
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
            GlassEffectContainer(spacing: 8) {
                VStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .center, spacing: 16) {
                        Button(action: { vm.goToChapter(.previous) }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundStyle(vm.hasPreviousChapter() ? .primary : .secondary)
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                                .glassEffect(.regular.interactive(), in: .circle)
                                .opacity(vm.hasPreviousChapter() ? 1 : 0.4)
                        }
                        .buttonStyle(.plain)
                        .disabled(!vm.hasPreviousChapter())

                        if !vm.images.isEmpty {
                            ReaderProgressSlider(vm: vm)
                        }

                        Button(action: { vm.goToChapter(.next) }) {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundStyle(vm.hasNextChapter() ? .primary : .secondary)
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                                .glassEffect(.regular.interactive(), in: .circle)
                                .opacity(vm.hasNextChapter() ? 1 : 0.4)
                        }
                        .buttonStyle(.plain)
                        .disabled(!vm.hasNextChapter())
                    }

                    if !vm.images.isEmpty {
                        Text("\(Int(vm.progressBarCurrent())) of \(Int(vm.progressBarCount()))")
                            .font(.footnote.italic())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .glassEffect()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .transition(.move(edge: .bottom))
        } else {
            if !vm.images.isEmpty {
                Text("\(Int(vm.progressBarCurrent())) / \(Int(vm.progressBarCount()))")
                    .font(.footnote.italic())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glassEffect()
                    .transition(.move(edge: !vm.showToolBar ? .bottom : .top))
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
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
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
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
            }
            .padding(.all)
            .offset(x: 0, y: vm.showToolBar ? 0 : -150)
            .glassEffect(in: .rect(cornerRadius: 20))
            .transition(.move(edge: vm.showToolBar ? .top : .bottom))
        }
    }
    
    @ViewBuilder
    func SelectedMenuItem(text: String, comparaison: Bool, systemImage: String = "checkmark") -> some View {
        if comparaison && !systemImage.isEmpty { Label(text, systemImage: systemImage) }
        else { Text(text) }
    }
}
