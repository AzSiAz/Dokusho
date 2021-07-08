//
//  LibraryView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI

struct LibraryTabView: View {
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(fetchRequest: MangaCollection.collectionFetchRequest) var collections: FetchedResults<MangaCollection>

    @StateObject var vm: LibraryVM

    var body: some View {
        NavigationView {
            TabView(selection: $vm.selectedTab) {
                ForEach(collections) { collection in
                    MangaCollectionPage(collection: collection)
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            if let refresh = vm.refreshStatus[collection] {
                                VStack {
                                    HStack {
                                        Text("\(refresh.refreshProgress)/\(refresh.refreshCount)")
                                            .font(.caption)
                                        Text(" - ")
                                            .font(.caption)
                                        Text(refresh.refreshTitle)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    .frame(minWidth: UIScreen.main.bounds.width, alignment: .leading)
                                    ProgressView(value: Float(refresh.refreshProgress), total: Float(refresh.refreshCount))
                                        .background(Color.gray)
                                        .progressViewStyle(.linear)
                                }
                                .padding(.top, 10)
                                .background(colorScheme == .dark ? Color.black : Color.white)
                            }
                        }
                        .padding(.horizontal, 5)
                        .tag(collections.firstIndex(of: collection) ?? 0)
                }
            }
            .searchable(text: $vm.searchText)
            .toolbar {
                ToolbarItem {
                    Image(systemName: "list.bullet.rectangle")
                        .onTapGesture { vm.showSettings.toggle() }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    // TODO: Cancel task when I know how it work^^
                    Button(action: { vm.refreshLib(for: collections[vm.selectedTab]) }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if !collections.isEmpty {
                        Button(action: { vm.showChangeFilter.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .symbolVariant(collections[vm.selectedTab].filter.isNotAll() ? .fill : .none)
                        }
                        .buttonStyle(.plain)
                        .actionSheet(isPresented: $vm.showChangeFilter) {
                            ActionSheet(title: Text("Change Filter"), buttons: [
                                .default(
                                    Text("All"),
                                    action: { vm.changeFilter(collection: collections[vm.selectedTab], newFilterState: .all) }),
                                .default(
                                    Text("Only Read"),
                                    action: { vm.changeFilter(collection: collections[vm.selectedTab], newFilterState: .read) }),
                                .default(
                                    Text("Only Unread"),
                                    action: { vm.changeFilter(collection: collections[vm.selectedTab], newFilterState: .unread) }),
                                .cancel()
                            ])
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .sheet(isPresented: $vm.showSettings, onDismiss: { vm.showSettings = false }) {
                ManageCollectionsModal()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct LibraryTabView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryTabView(vm: .init())
    }
}
