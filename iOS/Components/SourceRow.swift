//
//  SourceRow.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 05/06/2021.
//
import SwiftUI
import NukeUI
import MangaSource

struct SourceRow: View {
    var source: MiniSource
    
    @State var navigateTo: SourceFetchType = .latest
    @State var isNavigationActive = false
    
    var body: some View {
        HStack {
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
                .padding(.leading, 1)
            }
            
            Spacer()
            
            if source.supportLatest {
                HStack {
                    Button("Latest") {
                        navigateTo = .latest
                        isNavigationActive = true
                    }
                }
                .padding()
            }
            
            NavigationLink(
                destination: ExploreDetailView(fetchType: navigateTo, srcId: source.id),
                isActive: $isNavigationActive
            ) { EmptyView() }
        }
        .frame(minHeight: 50)
        .contentShape(Rectangle())
        .onTapGesture {
            navigateTo = .popular
            isNavigationActive = true
        }
    }
    
}
