//
//  SourceRow.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 05/06/2021.
//
import SwiftUI
import NukeUI

struct SourceRow: View {
    @Binding var source: Source
    
    var body: some View {
        HStack {
            LazyImage(source: source.icon) { state in
                if state.isLoading {
                    ProgressView()
                }
                if state.error != nil {
                    Color.red
                }
                
                if let image = state.image {
                    image
                        .resizingMode(.aspectFill)
                }
            }
            .animation(nil)
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(source.name)
                Text(source.lang.rawValue)
            }
            .padding(.leading, 8)
        }
    }
    
}
