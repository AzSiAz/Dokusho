//
//  LibraryView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.managedObjectContext) var coreDataCtx
    @EnvironmentObject var sourcesSvc: MangaSourceService

    @StateObject var vm: LibraryVM

    @State var showSettings = false
    @State var showChangeFilter = false
    @State var selectedTab = 0
    
    var columns: [GridItem] {
        var base = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            base = [GridItem(.adaptive(minimum: 180, maximum: 180))]
        }
        
        return base
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ForEach(vm.libState.collections) { collection in
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(vm.getMangas(collection: collection)) { manga in
                                NavigationLink(destination: MangaDetailView(vm: MangaDetailVM(for: sourcesSvc.getSource(sourceId: manga.source)!, mangaId: manga.id!, context: coreDataCtx, libState: vm.libState))) {
                                    ImageWithTextOver(title: manga.title!, imageUrl: manga.cover!)
                                        .frame(height: 180)
                                        .overlay(alignment: .topTrailing) {
                                            if manga.unreadChapterCount() > 0 {
                                                Text(String(manga.unreadChapterCount()))
                                                    .padding(2)
                                                    .foregroundColor(.white)
                                                    .background(Color.blue)
                                                    .clipShape(RoundedCorner(radius: 10, corners: [.topRight, .bottomLeft]))
                                            }
                                        }
                                        .contextMenu {
                                            if manga.unreadChapterCount() != 0 {
                                                Button(action: { vm.markMangaAsRead(for: manga) }) {
                                                    Text("Mark as read")
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        if vm.libState.isRefreshing {
                            ProgressView(value: Float(vm.libState.refreshProgress), total: Float(vm.libState.refreshCount))
                                .background(Color.gray)
                        }
                    }
                    .padding(.horizontal, 5)
                    .navigationBarTitle("\(collection.name!) (\(vm.getMangas(collection: collection).count))", displayMode: .inline)
                    .tag(vm.libState.collections.firstIndex(of: collection) ?? 0)
                }
            }
//            .searchable(text: $vm.searchText)
            .toolbar {
                ToolbarItem {
                    Image(systemName: "list.bullet.rectangle")
                        .onTapGesture { showSettings.toggle() }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { vm.libState.refreshManga(for: vm.libState.collections[selectedTab]) }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if !vm.libState.collections.isEmpty {
                        Button(action: { showChangeFilter.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .symbolVariant(vm.libState.collections[selectedTab].filter.isNotAll() ? .fill : .none)
                        }
                        .buttonStyle(.plain)
                        .actionSheet(isPresented: $showChangeFilter) {
                            ActionSheet(title: Text("Change Filter"), buttons: [
                                .default(
                                    Text("All"),
                                    action: { vm.changeFilter(collection: vm.libState.collections[selectedTab], newFilterState: .all) }),
                                .default(
                                    Text("Only Read"),
                                    action: { vm.changeFilter(collection: vm.libState.collections[selectedTab], newFilterState: .read) }),
                                .default(
                                    Text("Only Unread"),
                                    action: { vm.changeFilter(collection: vm.libState.collections[selectedTab], newFilterState: .unread) }),
                                .cancel()
                            ])
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .sheet(isPresented: $showSettings) {
                ManageCollectionsModal()
                    .environmentObject(vm.libState)
            }
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(vm: .init(libState: LibraryState(context: PersistenceController.init(inMemory: true).container.viewContext)))
    }
}
