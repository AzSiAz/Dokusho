//
//  ExploreDetailViewModels.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 06/06/2021.
//

import Foundation
import SwiftUI
import MangaSource

class ExploreDetailViewModel: ObservableObject {
    let src: Source
    
    var nextPage = 1
    @Published var fetchType: SourceFetchType
    @Published var mangas = [SourceSmallManga]()
    @Published var error = false
    
    init(_ fetchType: SourceFetchType, source: Source) {
        self.src = source
        self.fetchType = fetchType
    }
    
    func fetchList(clean: Bool = false) async {
        if clean {
            mangas = []
            nextPage = 1
        }
        
        do {
            let newManga = try await self.fetchType == .latest ? src.fetchLatestUpdates(page: nextPage) : src.fetchPopularManga(page: nextPage)

            self.mangas.append(contentsOf: newManga.mangas)
            self.nextPage += 1
        } catch {
            self.error = true
        }
    }
    
    func fetchMoreIfPossible(m: SourceSmallManga) async {
        if mangas.last == m {
            return await fetchList()
        }
    }
    
    func getTitle() -> String {
        return "\(src.name) - \(fetchType.rawValue)"
    }
}
