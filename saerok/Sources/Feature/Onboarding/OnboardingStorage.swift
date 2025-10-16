//
//  OnboardingStorage.swift
//  saerok
//
//  Created by HanSeung on 10/15/25.
//


import Foundation

struct OnboardingStorage {
    private static let defaults = UserDefaults.standard
    
    static func hasSeen(_ type: OnboardingType) -> Bool {
        defaults.bool(forKey: type.userDefaultsKey)
    }
    
    static func setSeen(_ type: OnboardingType) {
        defaults.set(true, forKey: type.userDefaultsKey)
    }
    
    static func reset(_ type: OnboardingType) {
        defaults.removeObject(forKey: type.userDefaultsKey)
    }
}
