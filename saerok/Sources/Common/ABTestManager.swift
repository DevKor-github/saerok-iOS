//
//  ABTestManager.swift
//  saerok
//
//  Created by HanSeung on 3/10/26.
//

import Foundation

final class ABTestManager {
    typealias Variant = CollectionDetailView.InteractionZoneVariant
    
    static let shared = ABTestManager()
    private let key = "ColletionDetail_interaction_zone_variant"

    private init() {}

    var interactionZoneVariant: Variant {
        if let saved = UserDefaults.standard.string(forKey: key),
           let variant = Variant(rawValue: saved) {
            return variant
        }

        let variant = Variant.allCases.randomElement()!
        UserDefaults.standard.set(variant.rawValue, forKey: key)
        return variant
    }
}
