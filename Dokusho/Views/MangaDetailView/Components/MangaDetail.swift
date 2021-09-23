//
//  MangaDetail.swift
//  Dokusho
//
//  Created by Stef on 23/09/2021.
//

import SwiftUI
import CoreData

struct MangaDetail: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @FetchRequest(sortDescriptors: [], predicate: nil, animation: nil)
    var collections: FetchedResults<CollectionEntity>

    @StateObject var orientation: DeviceOrientation = DeviceOrientation()
    @ObservedObject var manga: MangaEntity
    @Binding var selectedChapter: ChapterEntity?

    @State var addToCollection = false
    @State var showMoreDesc = false
    
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
            VStack {
                HeaderRow()
                ActionRow()
                SynopsisRow()
            }
            .frame(maxWidth: 500, alignment: .leading)
            .id("Detail")
            
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
            SynopsisRow()
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
                    
                    Text(manga.source?.name ?? "Unknown")
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
    func SynopsisRow() -> some View {
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

            VStack {
                FlexibleView(data: manga.genres ?? [], availableWidth: 490, spacing: 5, alignment: .center) { genre in
                    Button(genre.name ?? "Unknown", action: {})
                        .buttonStyle(.bordered)
                }
            }
        }
    }
}

