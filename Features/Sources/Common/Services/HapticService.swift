//
//  HapticService.swift
//  Dokusho (iOS)
//
//  Created by Claude on 2026.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

@MainActor
public enum HapticService {

    public static func chapterBoundaryReached() {
        guard Preferences.standard.hapticFeedbackEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    public static func chapterLoaded() {
        guard Preferences.standard.hapticFeedbackEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    public static func chapterLoadFailed() {
        guard Preferences.standard.hapticFeedbackEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
}
