//
//  MangaDetail.swift
//  Dokusho
//
//  Created by Stef on 23/09/2021.
//

import SwiftUI
import GRDBQuery
import SFSafeSymbols

struct MangaDetail: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @Query(MangaCollectionRequest()) var collections
    
    @ObservedObject var vm: MangaDetailVM
    @StateObject var orientation: DeviceOrientation = DeviceOrientation()    
    
    var body: some View {
        if !vm.showDismiss || (sizeClass == .compact || (UIDevice.current.userInterfaceIdiom == .pad && orientation.orientation == .portrait)) {
            CompactBody()
        } else {
            LargeBody()
        }
    }
    
    @ViewBuilder
    func LargeBody() -> some View {
        if let data = vm.data {
            HStack(alignment: .top, spacing: 5) {
                ScrollView {
                    VStack {
                        HeaderRow(data)
                        ActionRow(data)
                        SynopsisRow(data, isLarge: true)
                    }
                    .frame(maxWidth: 500, alignment: .leading)
                    .id("Detail")
                }
                
                Divider()
                
                ScrollView {
                    ChapterListInformation(manga: data.manga, scraper: vm.scraper)
                        .disabled(vm.refreshing)
                        .padding(.bottom)
                }
                .id("Chapter")
            }
            .frame(alignment: .leading)
        }
    }
    
    @ViewBuilder
    func CompactBody() -> some View {
        if let data = vm.data {
            ScrollView {
                HeaderRow(data)
                ActionRow(data)
                SynopsisRow(data, isLarge: false)
                ChapterListInformation(manga: data.manga, scraper: data.scraper!)
                    .disabled(vm.refreshing)
                    .padding(.bottom)
            }
        }
    }
    
    @ViewBuilder
    func HeaderRow(_ data: MangaWithDetail) -> some View {
        HStack(alignment: .top) {
            RemoteImageCacheView(url: data.manga.cover, contentMode: .fit)
                .frame(height: 180)
                .cornerRadius(10)
                .clipped()
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(data.manga.title)
                        .lineLimit(2)
                        .font(.subheadline.bold())
                }
                .padding(.bottom, 5)
                
                Divider()
                    .hidden()
                
                VStack(alignment: .center) {
                    VStack {
                        ForEach(data.manga.authors) { author in
                            Text(author)
                                .font(.caption.italic())
                        }
                    }
                    .padding(.bottom, 5)
                    
                    Text(data.manga.status.rawValue)
                        .font(.callout.bold())
                        .padding(.bottom, 5)
                    
                    // TODO: Change to source name
                    Text(data.scraper?.name ?? "No Name")
                        .font(.callout.bold())
                }
            }
        }
    }
    
    @ViewBuilder
    func ActionRow(_ data: MangaWithDetail) -> some View {
        ControlGroup {
            Button(action: {
                withAnimation {
                    vm.addToCollection.toggle()
                }
            }) {
                VStack(alignment: .center, spacing: 1) {
                    Image(systemName: "heart")
                        .symbolVariant(data.mangaCollection != nil ? .fill : .none)
                    // TODO: Change this to real collection name
                    Text(data.mangaCollection?.name ?? "Favoris")
                }
            }
            .buttonStyle(.plain)
            .actionSheet(isPresented: $vm.addToCollection) {
                var actions: [ActionSheet.Button] = []

                collections.forEach { col in
                    actions.append(.default(
                        Text(col.name),
                        action: {
                            vm.insertMangaInCollection(col)
                        }
                    ))
                }

                if let collectionName = vm.data?.mangaCollection?.name {
                    actions.append(.destructive(
                        Text("Remove from \(collectionName)"),
                        action: {
                            vm.removeMangaFromCollection()
                        }
                    ))
                }

                actions.append(.cancel())

                return ActionSheet(title: Text("Choose collection"), buttons: actions)
            }

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
        .controlGroupStyle(.navigation)
        .frame(height: 50)
        .padding(.bottom, 5)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func SynopsisRow(_ data: MangaWithDetail , isLarge: Bool) -> some View {
        let availableWidth = isLarge ? 490 : UIScreen.main.bounds.width
        
        VStack {
            VStack(spacing: 5) {
                Text(data.manga.synopsis)
                    .lineLimit(vm.showMoreDesc ? .max : 4)
                
                HStack {
                    Spacer()
                    Button(action: { withAnimation {
                        vm.showMoreDesc.toggle()
                    } }) {
                        Text("Show \(!vm.showMoreDesc ? "more" : "less")")
                    }
                }
            }
            .padding([.bottom, .horizontal])

            HStack {
                Text("Genres:")
                Spacer()
            }
            .padding(.horizontal)
            
            FlexibleView(data: data.manga.genres, availableWidth: availableWidth, spacing: 5, alignment: .center) { genre in
                Button(genre, action: { vm.selectedGenre = genre })
                    .buttonStyle(.bordered)
            }
            .sheetSizeAware(item: $vm.selectedGenre) { genre in
                MangaInCollectionForGenre(genre: genre)
            }
        }
    }
}


