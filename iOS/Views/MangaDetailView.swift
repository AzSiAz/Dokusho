//
//  MangaDetailView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI
import NukeUI

struct MangaDetailView: View {
    @StateObject var vm: MangaDetailVM
    @State var imageWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            if vm.error {
                VStack {
                    Text("Something weird happened, try again")
                    Button(action: {
                        async {
                            await vm.fetchManga()
                        }
                    }, label: {
                        Image(systemName: "arrow.counterclockwise")
                    })
                }
            }
            
            if !vm.error && vm.manga == nil {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
            }
            
            if let manga = vm.manga {
                ScrollView {
                    Header(manga)
                    Divider()
                    Information(manga)
                        .padding(.top, 5)
                        .padding(.bottom, 15)
                    Divider()
                    ChapterList(manga.chapters)
                        .padding(.bottom)
                }
                .refreshable { await vm.fetchManga() }
            }
        }
        .navigationTitle(vm.manga?.title ?? "Loading")
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
            ReaderView(vm: ReaderVM(for: chapter, in: vm.manga!, with: vm.src))
        }
    }
    
    fileprivate func Header(_ manga: SourceManga) -> some View {
        return HStack(alignment: .top) {
            LazyImage(source: manga.thumbnailUrl, resizingMode: .aspectFill)
                .onSuccess({ imageWidth = $0.image.size.width })
                .animation(nil)
                .frame(maxHeight: 180)
                .frame(width: imageWidth)
                .background(Color.red)
                .cornerRadius(10)
                .clipped()
                .padding(.leading, 10)
            
            VStack {
                VStack(alignment: .leading) {
                    Text(manga.title)
                        .lineLimit(2)
                        .font(Font.title3.bold())
                }
                
                Divider()
                
                VStack(alignment: .center) {
                    if !manga.authors.isEmpty {
                        Text(manga.authors.joined(separator: ", "))
                            .font(.system(size: 13))
                            .padding(.bottom, 5)
                    }
                    
                    Text(manga.status.rawValue)
                        .font(.system(size: 13))
                        .padding(.bottom, 5)
                    
                    Text(vm.getSourceName())
                        .font(.system(size: 13))
                }
            }
        }
    }
    
    fileprivate func Information(_ manga: SourceManga) -> some View {
        return VStack {
            Text(manga.description)
                .padding(.horizontal)
                .padding(.bottom)
            
            FlexibleView(data: manga.genres, spacing: 5, alignment: .leading) { genre in
                Button(genre, action: {})
                    .buttonStyle(.bordered)
            }
        }
    }
    
    fileprivate func ChapterList(_ chapters: [SourceChapter]) -> some View {
        return VStack(alignment: .leading) {
            HStack {
                Text("Chapter List")

                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .padding(.trailing, 5)
                
                Button(action: { vm.reverseChaptersOrder() }) {
                    Image(systemName: "chevron.up.chevron.down")
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            
            ForEach(chapters) { chapter in
                Button(action: { vm.selectChapter(for: chapter) }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(chapter.name)
                            Text(chapter.dateUpload.formatted())
                                .font(.system(size: 12))
                        }
                    }
                        
                    Spacer()
                    
                    Button(action: { print("download")}) {
                        Image(systemName: "icloud.and.arrow.down")
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
                .contentShape(Rectangle())

                Divider()
                    .padding(.leading, 15)
            }
            .padding(.horizontal, 10)
        }
    }
}

struct MangaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MangaDetailView(vm: MangaDetailVM(for: MangaSeeSource(), mangaId: "Ookii-Kouhai-wa-Suki-Desu-ka"))
    }
}

