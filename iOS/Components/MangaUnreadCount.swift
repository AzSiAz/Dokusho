//
//  MangaUnreadCount.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI

struct MangaUnreadCount: View {
    var count: Int
    
    init(count: Int) {
        self.count = count
    }
    
    var body: some View {
        if count != 0 {
            Text(String(count))
                .padding(2)
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(RoundedCorner(radius: 10, corners: [.topRight, .bottomLeft]))
        }
    }
}
