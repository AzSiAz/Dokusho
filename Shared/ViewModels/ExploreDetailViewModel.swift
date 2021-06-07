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
    
    init(_ fetchType: SourceFetchType, source: Source) {
        self.src = source
        self.fetchType = fetchType
    }
    
    func fetchList(clean: Bool = false) {
        switch self.fetchType {
            case .latest:
                fetchLatest(page: nextPage, clean: clean)
            case .popular:
                fetchPopular(page: nextPage, clean: clean)
        }
    }
    
    private func fetchLatest(page: Int, clean: Bool) {
        src.fetchLatestUpdates(page: page) { [self] res in
            switch res {
                case .failure(let error):
                    print(error)
                case .success(let page):
                    if !clean {
                        mangas.append(contentsOf: page.mangas)
                    }
                    else {
                        mangas = page.mangas
                    }
                    
                    nextPage += 1
            }
        }
    }
    
    private func fetchPopular(page: Int, clean: Bool) {
        src.fetchPopularManga(page: page) { [self] res in
            switch res {
                case .failure(let error):
                    print(error) 
                case .success(let page):
                    if !clean {
                        mangas.append(contentsOf: page.mangas)
                    }
                    else {
                        mangas = page.mangas
                    }
                    nextPage += 1
            }
        }
    }
    
    func fetchMoreIfPossible(m: SourceSmallManga) {
        if mangas.last == m {
            fetchList()
        }
    }
    
    func getTitle() -> String {
        return "\(src.name) - \(fetchType.rawValue)"
    }
}
