//
//  BottomOverlayView.swift
//  BottomOverlayView
//
//  Created by Stephan Deumier on 19/07/2021.
//

import SwiftUI

struct BottomOverlayView: View {
    @ObservedObject var vm: ReaderVM
    
    var body: some View {
        if vm.showToolBar {
            HStack(alignment: .top) {
                // TODO: Add a custom slider to be able to update tabIndex value
                ProgressView(value: vm.progressBarCurrent(), total: Double(vm.images.count))
            }
            .frame(height: 50, alignment: .center)
            .padding(.horizontal)
            .background(.thickMaterial)
        }
    }
}
