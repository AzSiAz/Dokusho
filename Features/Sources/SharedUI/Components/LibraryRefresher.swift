//
//  LibraryRefresher.swift
//  Dokusho
//
//  Created by Stef on 20/04/2022.
//

import Foundation
import SwiftUI

public struct LibraryRefresher: View {
    var title: String
    var progress: Double
    var total: Double
    
    public init(title: String, progress: Double, total: Double) {
        self.title = title
        self.progress = progress
        self.total = total
    }
    
    public var body: some View {
        VStack {
            Text(title)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.top, 15)
            ProgressView(value: progress, total: total)
                .padding(.horizontal, 10)
                .padding(.bottom, 2)
        }
        .background(.ultraThickMaterial)
        .clipShape(Rectangle())
        .cornerRadius(15)
        .padding(.horizontal, 50)
        .padding(.bottom, 55)
        .shadow(radius: 5)
    }
}
