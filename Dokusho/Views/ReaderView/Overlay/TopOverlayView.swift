//
//  TopOverlayView.swift
//  TopOverlayView
//
//  Created by Stephan Deumier on 19/07/2021.
//

import SwiftUI

struct TopOverlayView: View {
    @ObservedObject var vm: ReaderVM
    
    var inset: CGFloat
    var dismiss: () -> Void
    
    var body: some View {
        if vm.showToolBar {
            VStack {
                HStack {}
                    .frame(height: inset)
                HStack(alignment: .center) {
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
                .padding()
            }
            .offset(x: 0, y: vm.showToolBar ? 0 : -150)
            .padding(.horizontal)
            .background(.thickMaterial)
            .transition(.move(edge: vm.showToolBar ? .top : .bottom))
        }
    }
}
