//
//  MangaDetailView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI
import NukeUI

struct MangaDetailView: View {
    @EnvironmentObject var libState: LibraryState
    
    @StateObject var vm: MangaDetailVM

    @State var imageWidth: CGFloat = 0
    @State var addToCollection = false
    @State var showMoreDesc = false
    
    var body: some View {
        ZStack {
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
                    ScrollView {
                            Header(manga)
                                .padding(.bottom)
//                            Divider()
                            Information(manga)
                                .padding(.top, 5)
                                .padding(.bottom, 15)
                            Divider()
                            ChapterList(manga.chapters?.allObjects as? [MangaChapter] ?? [])
                                .padding(.bottom)
                    }
//                    .refreshable { await vm.fetchManga() }
                }
            }
        }
        .navigationBarTitle(vm.manga?.title ?? "Loading", displayMode: .large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Link(destination: self.vm.getMangaURL()) {
                    Image(systemName: "safari")
                        .resizable()
                }
            }
        }
        .task { await vm.fetchManga() }
        .fullScreenCover(item: $vm.selectedChapter) { chapter in
            ReaderView(vm: ReaderVM(for: chapter, with: vm.src, manga: vm.manga!, context: vm.ctx, libState: libState))
        }
    }
    
    fileprivate func Header(_ manga: Manga) -> some View {
        return Group {
            HStack(alignment: .top) {
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
                                ForEach(vm.authors()) { author in
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
    }
    
    fileprivate func Information(_ manga: Manga) -> some View {
        return VStack {
            HStack(alignment: .center) {
                Button(action: { addToCollection.toggle() }) {
                    VStack(alignment: .center, spacing: 1) {
                        Image(systemName: "heart")
                            .symbolVariant(vm.libState.isMangaInCollection(for: manga) ? .fill : .none)
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
            actions.append(contentsOf: vm.libState.collections.map { col in
                return ActionSheet.Button.default(
                    Text(col.name!),
                    action: { vm.libState.addMangaToCollection(manga: manga, collection: col) }
                )
            })
            if manga.collection != nil {
                actions.append(.destructive(Text("Remove from collection"), action: {
                    vm.libState.deleteMangaFromCollection(manga: manga, collection: manga.collection!)
                }))
            }
            
            actions.append(.cancel())
            
           return ActionSheet(title: Text("Choose collection"), buttons: actions)
        }
    }
    
    fileprivate func ChapterList(_ chapters: [MangaChapter]) -> some View {
        return VStack {
            HStack {
                Text("Chapter List")

                Spacer()
                
                Button(action: { vm.chapterFilter.toggle() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .symbolVariant(vm.chapterFilter == .all ? .none : .fill)
                }
                .padding(.trailing, 5)
                
                Button(action: { vm.chapterOrder.toggle() }) {
                    Image(systemName: "chevron.up.chevron.down")
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            
            ForEach(vm.chapters(), id: \.id) { chapter in
                ChapterListRow(vm: vm, chapter: chapter)
            }
            .padding(.horizontal, 10)
        }
    }
}

struct MangaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceController(inMemory: true).container.viewContext
        
        MangaDetailView(vm: MangaDetailVM(
            for: MangaSeeSource(),
            mangaId: "Ookii-Kouhai-wa-Suki-Desu-ka",
            context: ctx,
            libState: .init(context: ctx)
        ))
    }
}

