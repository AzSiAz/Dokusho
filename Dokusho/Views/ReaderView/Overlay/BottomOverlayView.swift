//
//  BottomOverlayView.swift
//  BottomOverlayView
//
//  Created by Stephan Deumier on 19/07/2021.
//

import SwiftUI

struct BottomOverlayView: View {
    @ObservedObject var vm: ReaderVM
    var inset: CGFloat
    
    var body: some View {
        if vm.showToolBar {
            VStack {
                HStack {
                    // TODO: Add a custom slider to be able to update tabIndex value
                    ProgressView(value: vm.progressBarCurrent(), total: Double(vm.images.count))
                }
                .padding(.vertical)
                .padding(.top, 10)

                HStack {}
                    .frame(height: inset)
            }
//            .frame(height: 50+inset, alignment: .center)
            .padding(.horizontal)
            .background(.thickMaterial)
            .offset(x: 0, y: vm.showToolBar ? 0 : 150)
            .transition(.move(edge: vm.showToolBar ? .bottom : .top))
        }
    }
}
