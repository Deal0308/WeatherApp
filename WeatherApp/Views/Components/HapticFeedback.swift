//
//  HapticFeedback.swift
//  WeatherApp
//
//  Provides small reusable haptic interactions for user-initiated UI actions.
//

import UIKit

enum HapticFeedback {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
