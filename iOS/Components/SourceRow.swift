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
            LazyImage(source: source.icon)
                .placeholder {
                    Circle()
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                }
                .failure { Image("empty") }
                .contentMode(.aspectFill)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(source.name)
                Text(source.lang.rawValue)
            }
            .padding(.leading, 8)
        }
    }
    
}
