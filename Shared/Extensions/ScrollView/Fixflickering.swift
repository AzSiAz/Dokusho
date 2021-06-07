//
//  Fixflickering.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 05/06/2021.
//

import SwiftUI

// Thanks to KoCMoHaBTa here https://stackoverflow.com/a/65218077 It's not a perfect solution but it will do until Apple fix it for iOS 15 (lol, let's hope)

extension ScrollView {
    
    public func fixFlickering() -> some View {
        
        return self.fixFlickering { (scrollView) in
            
            return scrollView
        }
    }
    
    public func fixFlickering<T: View>(@ViewBuilder configurator: @escaping (ScrollView<AnyView>) -> T) -> some View {
        
        GeometryReader { geometryWithSafeArea in
            GeometryReader { geometry in
                configurator(
                    ScrollView<AnyView>(self.axes, showsIndicators: self.showsIndicators) {
                        AnyView(
                            VStack {
                                self.content
                            }
                            .padding(.top, geometryWithSafeArea.safeAreaInsets.top)
                            .padding(.bottom, geometryWithSafeArea.safeAreaInsets.bottom)
                            .padding(.leading, geometryWithSafeArea.safeAreaInsets.leading)
                            .padding(.trailing, geometryWithSafeArea.safeAreaInsets.trailing)
                        )
                    }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
