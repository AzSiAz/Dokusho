//
//  MangaDetailInformation.swift
//  MangaDetailInformation
//
//  Created by Stephan Deumier on 20/07/2021.
//

import SwiftUI

struct MangaDetailInformation: View {
    @ObservedObject var vm: MangaDetailVM
//    @FetchRequest(fetchRequest: MangaCollection.collectionFetchRequest) var collections: FetchedResults<MangaCollection>
    
    var body: some View {
        VStack {
            if let manga = vm.manga {
                HStack(alignment: .center) {
                    Button(action: { vm.addToCollection.toggle() }) {
                        VStack(alignment: .center, spacing: 1) {
                            Image(systemName: "heart")
//                                .symbolVariant(manga.collection != nil ? .fill : .none)
                            Text("Favoris")
                        }
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.horizontal)
                    
                    AsyncButton(action: { await vm.update() }) {
                        VStack(alignment: .center, spacing: 1) {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    AsyncButton(action: { await vm.resetCache() }) {
                        VStack(alignment: .center, spacing: 1) {
                            Image(systemName: "xmark.bin.circle")
                            Text("Reset cache")
                        }
                    }
                }
                .frame(height: 50)
                .padding(.bottom, 5)
                .padding(.horizontal)
                
                VStack(spacing: 5) {
                    Text(manga.synopsis ?? "...")
                        .lineLimit(vm.showMoreDesc ? .max : 4)
                    
                    HStack {
                        Spacer()
                        Button(action: { vm.showMoreDesc.toggle() }) {
                            Text("Show \(!vm.showMoreDesc ? "more" : "less")")
                        }
                    }
                }
                .padding([.bottom, .horizontal])

                FlexibleView(data: vm.manga?.genres ?? [], spacing: 5, alignment: .leading) { genre in
                    Button(genre.name ?? "", action: {})
                        .buttonStyle(.bordered)
                }
            }
        }
//        .actionSheet(isPresented: $vm.addToCollection) {
//            var actions: [ActionSheet.Button] = []
//            
//            collections.forEach { col in
//                actions.append(.default(
//                    Text(col.name!),
//                    action: {
//                        DataManager.shared.insertMangaInCollection(for: vm.manga!, in: col)
//                        Task { await vm.fetchManga() }
//                    }
//                ))
//            }
//
//            if vm.manga!.collection != nil {
//                actions.append(.destructive(Text("Remove from \(vm.manga!.collection?.name ?? "")"), action: {
//                    DataManager.shared.removeMangaFromCollection(for: vm.manga!, in: vm.manga!.collection!)
//                    Task { await vm.fetchManga() }
//                }))
//            }
//            
//            actions.append(.cancel())
//            
//            return ActionSheet(title: Text("Choose collection"), buttons: actions)
//        }
    }
}
