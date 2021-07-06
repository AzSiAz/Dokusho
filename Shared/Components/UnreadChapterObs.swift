//
//  UnreadChapterObs.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/07/2021.
//

import SwiftUI

struct UnreadChapterObs<Content: View>: View {
    var count: Int
    
    var content: (_ count: Int) -> Content
    
    init(manga: Manga, @ViewBuilder content: @escaping (_ count: Int) -> Content) {
        self.content = content
        self.count = manga.chapters?.filter({ $0.isUnread }).count ?? 0
    }
    
    var body: some View {
        return content(count)
    }
}
