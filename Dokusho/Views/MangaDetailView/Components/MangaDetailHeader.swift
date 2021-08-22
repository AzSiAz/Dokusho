//
//  MangaDetailHeader.swift
//  MangaDetailHeader
//
//  Created by Stephan Deumier on 20/07/2021.
//

import SwiftUI

struct MangaDetailHeader: View {
    @ObservedObject var vm: MangaDetailVM
    
    var body: some View {
        if vm.manga != nil {
            HStack(alignment: .top) {
                RemoteImageCacheView(url: vm.manga?.cover, contentMode: .fit)
                    .frame(height: 180)
                    .cornerRadius(10)
                    .clipped()
                    .padding(.leading, 10)
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text(vm.manga?.title ?? "")
                            .lineLimit(2)
                            .font(.subheadline.bold())
                    }
                    .padding(.bottom, 5)
                    
                    Divider()
                        .hidden()
                    
                    VStack(alignment: .center) {
                        VStack {
                            ForEach(vm.manga?.authorsAndArtists?.allObjects as? [AuthorAndArtistEntity] ?? [] , id: \.self) { author in
                                Text("\(author.name ?? "")")
                                    .font(.caption.italic())
                            }
                        }
                        .padding(.bottom, 5)
                        
                        Text(vm.manga?.statusRaw ?? "")
                            .font(.callout.bold())
                            .padding(.bottom, 5)
                        
                        Text(vm.getSourceName())
                            .font(.callout.bold())
                    }
                }
            }
        }
    }
}
