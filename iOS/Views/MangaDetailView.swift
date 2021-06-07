//
//  MangaDetailView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI
import MangaSource

struct MangaDetailView: View {
    var manga: SourceSmallManga
    
    var body: some View {
        VStack {
            Text(manga.title)
            Text(manga.id)
        }
    }
}

struct MangaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MangaDetailView(manga: SourceSmallManga(id: "Ookii-Kouhai-wa-Suki-Desu-ka", title: "Ookii Kouhai wa Suki Desu ka", thumbnailUrl: "https://cover.nep.li/cover/Ookii-Kouhai-wa-Suki-Desu-ka.jpg"))
    }
}
