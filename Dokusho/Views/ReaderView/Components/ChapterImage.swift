//
//  ChapterImage.swift
//  Dokusho
//
//  Created by Stef on 02/10/2021.
//

import SwiftUI
import ImageScrollView
import Nuke

//struct ChapterImage: UIViewRepresentable {
//    var url: String
//    var size: CGSize
//    
//    @State var imageView = UIImageView()
//
//    func makeUIView(context: Context) -> ImageScrollView {
//        Nuke.loadImage(with: url, into: imageView)
//        
//        let img = ImageScrollView()
//        img.setup()
//        img.imageContentMode = .aspectFit
//        img.initialOffset = .center
//        img.display(image: imageView.image ?? UIImage(systemName: "progress") ?? UIImage())
//        img.contentSize = size
//        img.layoutIfNeeded()
//        
////        img.delegate = context.coordinator
//        
//        return img
//    }
//    
//    func updateUIView(_ uiView: ImageScrollView, context: Context) {
////        let imageView = UIImageView()
////        Nuke.loadImage(with: url, into: imageView)
//        
//        uiView.display(image: imageView.image ?? UIImage())
//        uiView.contentSize = size
//        uiView.layoutIfNeeded()
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, ImageScrollViewDelegate {
//        var parent: ChapterImage
//
//        init(_ img: ChapterImage) {
//            parent = img
//        }
//        
//        func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
//            print("Did change orientation")
//        }
//        
//        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//            print("scrollViewDidEndZooming at scale \(scale)")
//        }
//        
//        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            print("scrollViewDidScroll at offset \(scrollView.contentOffset)")
//        }
//    }
//}
