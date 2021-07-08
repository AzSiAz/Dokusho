//
//  MangaDetailView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI
import NukeUI

struct MangaDetailView: View {
    @Environment(\.dismiss) var dismiss

    var dataManager = DataManager.shared

    @StateObject var vm: MangaDetailVM

    @State var imageWidth: CGFloat = 0
    @State var addToCollection = false
    @State var showMoreDesc = false
    @State var selectedChapter: MangaChapter?
    
    var body: some View {
        NavigationView {
            ScrollView {
                if vm.error {
                    VStack {
                        Text("Something weird happened, try again")
                        Button(action: {
                            async {
                                await vm.fetchManga()
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
                
                if !vm.error && vm.manga == nil {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity)
                }
                
                if !vm.error {
                    if let manga = vm.manga {
                        Header(manga)
                            .padding(.bottom)
                        Information(manga)
                            .padding(.top, 5)
                            .padding(.bottom, 15)
                        Divider()
                        ChapterListView(vm: .init(mangaId: vm.mangaId), selectedChapter: $selectedChapter)
                                .padding(.bottom)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "chevron.down")
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Link(destination: self.vm.getMangaURL()) {
                        Image(systemName: "safari")
                    }
                }
            }
            .refreshable { await vm.fetchManga() }
            // TODO: Fix when .task is working as expected
            .onAppear { async { await vm.fetchManga() } }
            .fullScreenCover(item: $selectedChapter) { chapter in
                ReaderView(vm: .init(for: chapter))
            }
        }
    }
    
    fileprivate func Header(_ manga: Manga) -> some View {
        return HStack(alignment: .top) {
            LazyImage(source: manga.cover, resizingMode: .aspectFill)
                .onSuccess({ imageWidth = $0.image.size.width })
                .animation(nil)
                .frame(maxHeight: 180)
                .frame(width: imageWidth)
                .background(Color.red)
                .cornerRadius(10)
                .clipped()
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(manga.title!)
                        .lineLimit(2)
                        .font(.subheadline.bold())
                }
                .padding(.bottom, 5)
                
                Divider()
                    .hidden()
                
                VStack(alignment: .center) {
                    if manga.authors?.count != 0 {
                        VStack {
                            ForEach(vm.authors(), id: \.name) { author in
                                Text("\(author.name!) ")
                                    .font(.caption.italic())
                            }
                        }
                        .padding(.bottom, 5)
                    }
                    
                    Text(manga.status.rawValue)
                        .font(.callout.bold())
                        .padding(.bottom, 5)
                    
                    Text(vm.getSourceName())
                        .font(.callout.bold())
                }
            }
        }
    }
    
    fileprivate func Information(_ manga: Manga) -> some View {
        return VStack {
            HStack(alignment: .center) {
                Button(action: { addToCollection.toggle() }) {
                    VStack(alignment: .center, spacing: 1) {
                        Image(systemName: "heart")
                            .symbolVariant(dataManager.isMangaInCollection(for: manga) ? .fill : .none)
                        Text("Favoris")
                    }
                }
                Divider()
                    .padding(.horizontal)
                Button(action: { async { await vm.refresh() } }) {
                    VStack(alignment: .center, spacing: 1) {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                }
                Divider()
                    .padding(.horizontal)
                Button(action: { vm.resetCache() }) {
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
                Text(manga.desc!)
                    .lineLimit(showMoreDesc ? .max : 4)
                
                HStack {
                    Spacer()
                    Button(action: { showMoreDesc.toggle() }) {
                        Text("Show \(!showMoreDesc ? "more" : "less")")
                    }
                }
            }
            .padding([.bottom, .horizontal])
            
            
            FlexibleView(data: vm.genres(), spacing: 5, alignment: .leading) { genre in
                Button(genre.name!, action: {})
                    .buttonStyle(.bordered)
            }
        }
        .actionSheet(isPresented: $addToCollection) {
            var actions: [ActionSheet.Button] = []

            if let collections = dataManager.getCollections() {
                collections.forEach { col in
                        actions.append(.default(
                            Text(col.name!),
                            action: {
                                dataManager.insertMangaInCollection(for: manga, in: col)
                                async {
                                    await vm.fetchManga()
                                }
                            }
                        ))
                }
            }
            if manga.collection != nil {
                actions.append(.destructive(Text("Remove from \(manga.collection?.name ?? "")"), action: {
                    dataManager.removeMangaFromCollection(for: manga, in: manga.collection!)
                    async {
                        await vm.fetchManga()
                    }
                }))
            }

            actions.append(.cancel())

           return ActionSheet(title: Text("Choose collection"), buttons: actions)
        }
    }
}

