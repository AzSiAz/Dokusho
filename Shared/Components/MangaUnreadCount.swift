//
//  MangaUnreadCount.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI
import SharedUI

struct MangaUnreadCount: View {
    var count: Int
    
    var body: some View {
        if count != 0 {
            Text(String(count))
                .padding(2)
                .foregroundColor(.primary)
                .background(.thinMaterial, in: RoundedCorner(radius: 10, corners: [.topRight, .bottomLeft]))
                .clipShape(RoundedCorner(radius: 10, corners: [.topRight, .bottomLeft]))
        }
    }
}
