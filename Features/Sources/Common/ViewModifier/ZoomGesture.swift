import SwiftUI

public struct PinchAndPanImage: ViewModifier {
    // For Drag Gesture
    @State var size: CGSize = .zero
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero
    
    // For magnification Gesture
    @State var scale: CGFloat = 1
    @State var lastScale: CGFloat = 1
    
    @Binding var isZooming: Bool
    
    public func body(content: Content) -> some View {
        content
            .readSize { size = $0 }
            .scaleEffect(scale < 1 ? 1 : scale)
            .offset(offset)
            .gesture(magnificationGesture().simultaneously(with: dragGesture()).simultaneously(with: TapGesture(count: 2).onEnded(reset)))
    }
    
    func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged({ value in
                isZooming = true
                // MARK: It Starts With Existing Scaling which is 1
                // Removing That to Retreive Exact Scaling
                scale = lastScale + (value - 1)
            }).onEnded({ value in
                lastScale = scale
                if scale == 1 {
                    isZooming = false
                }
            })
    }
    
    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: getMinimalDistance(), coordinateSpace: .local)
            .onChanged({ value in
                offset = CGSize(width: lastOffset.width + value.translation.width, height: lastOffset.height + value.translation.height)
            }).onEnded({ value in
                lastOffset = offset
            })
    }
    
    func reset() {
        withAnimation(.easeIn(duration: 0.25)) {
            scale = 1
            offset = .zero
            lastScale = scale
            lastOffset = offset
            isZooming = false
        }
    }
    
    func getMinimalDistance() -> Double {
        scale > 1 ? 0 : 10000
    }
}
