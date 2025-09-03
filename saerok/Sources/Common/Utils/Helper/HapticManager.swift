//
//  HapticManager.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


import Foundation
import SwiftUI
import UIKit

enum HapticType {
    case light, medium, heavy, success, warning, error
}

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func trigger(_ type: HapticType) {
        switch type {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

extension View {
    func haptic(_ type: HapticType) -> some View {
        self.onTapGesture {
            HapticManager.shared.trigger(type)
        }
    }
}
