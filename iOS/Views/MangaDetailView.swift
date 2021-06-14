//
//  MangaDetailView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI

struct MangaDetailView: View {
    var manga: SourceSmallManga
    
    init(for manga: SourceSmallManga, in sourceId: Int) {
        self.manga = manga
    }

    var body: some View {
        VStack {
            Text(manga.title)
            Text(manga.id)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                
            }
        }
    }
}

struct MangaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MangaDetailView(for: SourceSmallManga(id: "Ookii-Kouhai-wa-Suki-Desu-ka", title: "Ookii Kouhai wa Suki Desu ka", thumbnailUrl: "https://cover.nep.li/cover/Ookii-Kouhai-wa-Suki-Desu-ka.jpg"), in: 1)
    }
}
