//
//  RefreshableImageView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import SwiftUI

struct RefreshableImageView: View {
    @State var url: String
    @State var size: CGSize
    @State var id = UUID()
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { state in
            switch state {
                case .success(let image):
                    image
                        .resizable()
                case .failure(let err as NSError):
                    VStack {
                        Button(action: { id = UUID() }) {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                        
                        Text("Error: \(err)")
                    }
                    .frame(height: size.height)
                default:
                    ProgressView()
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .scaleEffect(3)
            }
        }
        .id(id)
    }
}

struct RefreshableImageView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableImageView(url: "", size: CGSize(width: 100, height: 100))
    }
}
