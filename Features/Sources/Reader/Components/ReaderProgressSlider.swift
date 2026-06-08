//
//  ReaderProgressSlider.swift
//  Dokusho
//
//  Custom interactive Liquid Glass scrubber for the reader.
//

import SwiftUI

/// An interactive glass scrubber that shows reading progress and lets the
/// reader jump to any page by dragging. Honors right-to-left reading direction.
struct ReaderProgressSlider: View {
    var vm: ReaderVM

    var body: some View {
        let count = max(vm.progressBarCount(), 1)
        let fraction = min(max(vm.progressBarCurrent() / count, 0), 1)
        let isRTL = vm.direction == .rightToLeft

        GeometryReader { geo in
            ZStack(alignment: isRTL ? .trailing : .leading) {
                Capsule()
                    .fill(.white.opacity(0.7))
                    .frame(width: max(0, geo.size.width * fraction))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Capsule())
            .glassEffect(.regular.interactive(), in: .capsule)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        var f = value.location.x / geo.size.width
                        if isRTL { f = 1 - f }
                        vm.scrub(toFraction: f)
                    }
            )
        }
        .frame(height: 28)
    }
}
