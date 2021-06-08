//
//  ExploreDetailView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 05/06/2021.
//

import SwiftUI
import MangaSource
import NukeUI

struct ExploreDetailView: View {
    @StateObject var vm: ExploreDetailViewModel
    
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
    
    init(fetchType: SourceFetchType, srcId: Int) {
        let source = MangaSourceService.shared.getSourceById(srcId)
        self._vm = .init(wrappedValue: ExploreDetailViewModel(fetchType, source: source))
    }
    
    var body: some View {
        ZStack {
            if vm.mangas.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            
            if !vm.mangas.isEmpty {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(vm.mangas) { manga in
                            NavigationLink(destination: MangaDetailView(manga: manga)) {
                                ImageWithTextOver(title: manga.title, imageUrl: manga.thumbnailUrl)
                                    .frame(height: 180)
                                    .onAppear {
                                        detach {
                                            await vm.fetchMoreIfPossible(m: manga)
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }
                // Not Working as of now
                .refreshable { await vm.fetchList(clean: true) }
            }
        }
        .navigationTitle(vm.getTitle())
        .onAppear {
            detach {
                await vm.fetchList()
            }
        }
    }
}

struct ExploreDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreDetailView(fetchType: .latest, srcId: 1)
    }
}
