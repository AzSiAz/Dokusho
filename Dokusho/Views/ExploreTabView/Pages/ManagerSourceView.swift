//
//  ManagerSourceView.swift
//  ManagerSourceView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI

struct ManagerSourceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Favorite Source(s)") {
                    FavoriteSourceSectionView(swipe: true)
                }
                
                Section("Active Source(s)") {
                    ActiveSourceSectionView(swipe: true)
                }
                
                Section("Other Source(s)") {
                    NotFavoriteOrActiveSourceSectionView(swipe: true)
                }
            }
            .listStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Label("dismiss", systemImage: "xmark")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Manage Sources")
        }
    }
}
