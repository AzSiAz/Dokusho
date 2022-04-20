//
//  LibraryRefresher.swift
//  Dokusho
//
//  Created by Stef on 20/04/2022.
//

import Foundation
import SwiftUI

struct LibraryRefresher: View {
    @EnvironmentObject var libraryUpdater: LibraryUpdater
    
    var body: some View {
        if let refresh = libraryUpdater.refreshStatus {
            VStack {
                Text(refresh.refreshTitle)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.top, 15)
                ProgressView(value: Double(refresh.refreshProgress), total: Double(refresh.refreshCount))
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
}
