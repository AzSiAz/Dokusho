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
            TabView {
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
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                    .navigationBarTitle(collection.name!)
                    .searchable(text: $vm.searchText)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showChangeFilter.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolVariant(vm.libFilter.isNotAll() ? .fill : .none)
                    }
                    .buttonStyle(.plain)
                    .actionSheet(isPresented: $showChangeFilter) {
                        ActionSheet(title: Text("Change Filter"), buttons: [
                            .default(Text("All"), action: { vm.changeFilter(newFilterState: .all) }),
                            .default(Text("Only Read"), action: { vm.changeFilter(newFilterState: .read) }),
                            .default(Text("Only Unread"), action: { vm.changeFilter(newFilterState: .unread) }),
                            .cancel()
                        ])
                    }
                }
                ToolbarItem {
                    Image(systemName: "gear")
                        .onTapGesture {
                            showSettings.toggle()
                        }
                }
            }
            .sheet(isPresented: $showSettings) {
                ManageCollectionsModal()
                    .environmentObject(vm.libState)
            }
        }
        .navigationTitle("Library")
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(vm: .init(libState: LibraryState(context: PersistenceController.init(inMemory: true).container.viewContext)))
    }
}
