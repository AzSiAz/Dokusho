//
//  MangaDetail.swift
//  Dokusho
//
//  Created by Stef on 23/09/2021.
//

import SwiftUI
import CoreData
import SFSafeSymbols

struct MangaDetail: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @FetchRequest<CollectionEntity>(sortDescriptors: [], predicate: nil, animation: nil) var collections

    @StateObject var orientation: DeviceOrientation = DeviceOrientation()
    @ObservedObject var manga: MangaEntity
    @Binding var selectedChapter: ChapterEntity?

    @State var addToCollection = false
    @State var showMoreDesc = false
    @State var selectedGenre: GenreEntity?
    
    let isInCollectionPage: Bool
    var forceCompact: Bool
    var update: () async -> Void
    var resetCache: () async -> Void
    var insertMangaInCollection: @MainActor (_ collectionId: NSManagedObjectID) -> Void
    var removeMangaFromCollection: @MainActor () -> Void
    
    var body: some View {
        if forceCompact || (sizeClass == .compact || (UIDevice.current.userInterfaceIdiom == .pad && orientation.orientation == .portrait)) {
            CompactBody()
        } else {
            LargeBody()
        }
    }
    
    @ViewBuilder
    func LargeBody() -> some View {
        HStack(alignment: .top, spacing: 5) {
            ScrollView {
                VStack {
                    HeaderRow()
                    ActionRow()
                    SynopsisRow(isLarge: true)
                }
                .frame(maxWidth: 500, alignment: .leading)
                .id("Detail")
            }
            
            Divider()
            
            ScrollView {
                ChapterListInformation(manga: manga, selectedChapter: $selectedChapter)
                    .padding(.bottom)
            }
            .id("Chapter")
        }
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
    }
    
    @ViewBuilder
    func CompactBody() -> some View {
        ScrollView {
            HeaderRow()
            ActionRow()
            SynopsisRow(isLarge: false)
            ChapterListInformation(manga: manga, selectedChapter: $selectedChapter)
                .padding(.bottom)
        }
    }
    
    @ViewBuilder
    func HeaderRow() -> some View {
        HStack(alignment: .top) {
            RemoteImageCacheView(url: manga.cover, contentMode: .fit)
                .frame(height: 180)
                .cornerRadius(10)
                .clipped()
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(manga.title ?? "")
                        .lineLimit(2)
                        .font(.subheadline.bold())
                }
                .padding(.bottom, 5)
                
                Divider()
                    .hidden()
                
                VStack(alignment: .center) {
                    VStack {
                        ForEach(manga.authorsAndArtists?.sorted(using: SortDescriptor(\AuthorAndArtistEntity.name)) ?? [], id: \.self) { author in
                            Text("\(author.name ?? "")")
                                .font(.caption.italic())
                        }
                    }
                    .padding(.bottom, 5)
                    
                    Text(manga.statusRaw ?? "")
                        .font(.callout.bold())
                        .padding(.bottom, 5)
                    
                    Text(manga.getSource().name)
                        .font(.callout.bold())
                }
            }
        }
    }
    
    @ViewBuilder
    func ActionRow() -> some View {
        HStack(alignment: .center) {
            Button(action: { withAnimation {
                addToCollection.toggle()
            } }) {
                VStack(alignment: .center, spacing: 1) {
                    Image(systemName: "heart")
                        .symbolVariant(manga.collection != nil ? .fill : .none)
                    Text("Favoris")
                }
            }
            .buttonStyle(.plain)
            .actionSheet(isPresented: $addToCollection) {
                var actions: [ActionSheet.Button] = []
                
                collections.forEach { col in
                    actions.append(.default(
                        Text(col.name!),
                        action: {
                            insertMangaInCollection(col.objectID)
                        }
                    ))
                }

                if manga.collection != nil {
                    actions.append(.destructive(
                        Text("Remove from \(manga.collection?.name ?? "")"),
                        action: {
                            removeMangaFromCollection()
                        }
                    ))
                }
                
                actions.append(.cancel())
                
                return ActionSheet(title: Text("Choose collection"), buttons: actions)
            }

            Divider()
                .padding(.horizontal)
            
            AsyncButton(action: { await update() }) {
                VStack(alignment: .center, spacing: 1) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
            }
            
            Divider()
                .padding(.horizontal)
            
            AsyncButton(action: { await resetCache() }) {
                VStack(alignment: .center, spacing: 1) {
                    Image(systemName: "xmark.bin.circle")
                    Text("Reset cache")
                }
            }
        }
        .frame(height: 50)
        .padding(.bottom, 5)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func SynopsisRow(isLarge: Bool) -> some View {
        let availableWidth = isLarge ? 490 : UIScreen.main.bounds.width
        
        VStack {
            VStack(spacing: 5) {
                Text(manga.synopsis ?? "...")
                    .lineLimit(showMoreDesc ? .max : 4)
                
                HStack {
                    Spacer()
                    Button(action: { withAnimation {
                        showMoreDesc.toggle()
                    } }) {
                        Text("Show \(!showMoreDesc ? "more" : "less")")
                    }
                }
            }
            .padding([.bottom, .horizontal])

            HStack {
                Text("Genres:")
                Spacer()
            }
            .padding(.horizontal)
            
            FlexibleView(data: manga.genres.sorted(by: \.name!), availableWidth: availableWidth, spacing: 5, alignment: .center) { genre in
                Button(genre.name ?? "Unknown", action: { selectedGenre = genre })
                    .buttonStyle(.bordered)
            }
            .sheetSizeAware(item: $selectedGenre) { genre in
                if isInCollectionPage {
                    MangaInCollectionForGenre(genre: genre)
                } else {
                    ScrollView {
                        Text(selectedGenre?.name ?? "Genre")
                    }
                }
            }
        }
    }
}


