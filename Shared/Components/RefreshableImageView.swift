//
//  RefreshableImageView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import SwiftUI

struct RefreshableImageView: View {
    @State var url: String
    @State var refresh: Bool = false
    @State var size: CGSize
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { state in
            switch state {
                case .success(let image):
                    image
                        .resizable()
                case .failure(_):
                    VStack {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .frame(width: 64)
                        Text("Refresh")
                    }
                    .frame(width: size.width, height: size.height, alignment: .center)
                    .onTapGesture { refresh.toggle() }
                default:
                    ProgressView()
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .scaleEffect(3)
            }
        }
    }
}

struct RefreshableImageView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableImageView(url: "", size: CGSize(width: 100, height: 100))
    }
}
