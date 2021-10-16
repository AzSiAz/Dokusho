//
//  TopOverlayView.swift
//  TopOverlayView
//
//  Created by Stephan Deumier on 19/07/2021.
//

import SwiftUI

struct TopOverlayView: View {
    @ObservedObject var vm: ReaderVM
    
    var dismiss: () -> Void
    
    var body: some View {
        if vm.showToolBar {
            HStack(alignment: .top) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                }
                Spacer()
                
                Text(vm.chapter.title!)
                    .foregroundColor(.primary)
                
                Spacer()
                Button(action: { vm.showReaderDirectionChoice.toggle() }) {
                    Image(systemName: "slider.vertical.3")
                }
                .actionSheet(isPresented: $vm.showReaderDirectionChoice) {
                    var actions: [ActionSheet.Button] = ReadingDirection.allCases.map { dir in
                        return .default(Text(dir.rawValue), action: { self.vm.direction = dir })
                    }
                    actions.append(.cancel())
                    
                    return ActionSheet(
                        title: Text("Choose reader direction"),
                        message: Text("Not saved for now"),
                        buttons: actions
                    )
                }
            }
            .frame(height: 50, alignment: .center)
            .padding(.horizontal)
            .background(.thickMaterial)
        }
    }
}
