//
//  DeviceOrientation.swift
//  Dokusho
//
//  Created by Stef on 23/09/2021.
//

import SwiftUI
import Combine

@Observable
public final class DeviceOrientation {
    public enum Orientation {
        case portrait, landscape
    }
    
    public var orientation: Orientation
   
    @ObservationIgnored
    private var listener: AnyCancellable?
    
    public init() {
        orientation = UIDevice.current.orientation.isLandscape ? .landscape : .portrait
        listener = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { ($0.object as? UIDevice)?.orientation }
            .compactMap { deviceOrientation -> Orientation? in
                if deviceOrientation.isPortrait {
                    return .portrait
                } else if deviceOrientation.isLandscape {
                    return .landscape
                } else {
                    return nil
                }
            }
            .assign(to: \.orientation, on: self)
    }
    
    deinit {
        listener?.cancel()
    }
}
