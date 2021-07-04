//
//  LibraryView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var sourcesSvc: MangaSourceService
    @Environment(\.colorScheme) var colorScheme

    @StateObject var vm: LibraryVM

    var body: some View {
        NavigationView {
            TabView(selection: $vm.selectedTab) {
                ForEach($vm.collections) { collection in
                    MangaCollectionPage(vm: vm, collection: collection)
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            if let refresh = vm.refreshStatus[collection.wrappedValue] {
                                VStack {
                                    Text(refresh.refreshTitle)
                                        .font(.caption)
                                    ProgressView(value: Float(refresh.refreshProgress), total: Float(refresh.refreshCount))
                                        .background(Color.gray)
                                        .progressViewStyle(.linear)
                                }
                                .padding(.top, 10)
                                .background(colorScheme == .dark ? Color.black : Color.white)
                            }
                        }
                        .padding(.horizontal, 5)
                        .navigationBarTitle("\(collection.wrappedValue.name!) (\(vm.getMangas(collection: collection.wrappedValue).count))", displayMode: .inline)
                        .tag(vm.collections.firstIndex(of: collection.wrappedValue) ?? 0)
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
                    Button(action: { vm.refreshLib(for: vm.collections[vm.selectedTab]) }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if !vm.collections.isEmpty {
                        Button(action: { vm.showChangeFilter.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .symbolVariant(vm.collections[vm.selectedTab].filter.isNotAll() ? .fill : .none)
                        }
                        .buttonStyle(.plain)
                        .actionSheet(isPresented: $vm.showChangeFilter) {
                            ActionSheet(title: Text("Change Filter"), buttons: [
                                .default(
                                    Text("All"),
                                    action: { vm.changeFilter(collection: vm.collections[vm.selectedTab], newFilterState: .all) }),
                                .default(
                                    Text("Only Read"),
                                    action: { vm.changeFilter(collection: vm.collections[vm.selectedTab], newFilterState: .read) }),
                                .default(
                                    Text("Only Unread"),
                                    action: { vm.changeFilter(collection: vm.collections[vm.selectedTab], newFilterState: .unread) }),
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
            .navigationViewStyle(.stack)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(vm: .init())
    }
}
