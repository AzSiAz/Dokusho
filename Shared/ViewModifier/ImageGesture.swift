//
//  ImageGesture.swift
//  Dokusho
//
//  Created by Stef on 29/12/2021.
//

import Foundation
import SwiftUI
import ZoomableImageView

extension View {
    func addGestureToChapterImage(size: CGSize) -> some View {
        return ImageGestureContext(size: size) {
            self
        }
    }
}

struct ImageGestureContext<Content: View>: View{

    var content: Content
    var size: CGSize

    init(size: CGSize, @ViewBuilder content: @escaping ()->Content){
        self.content = content()
        self.size = size
    }

    var body: some View{
        content
    }
}
