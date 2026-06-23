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

    /// Amplitude 로깅용 변형. UI 렌더링에 쓰는 `interactionZoneVariant`와
    /// 동일한 저장값에서 파생되므로 화면과 로그가 항상 일치한다.
    var detailUIVariant: DetailUIVariant {
        switch interactionZoneVariant {
        case .a: return .variantA
        case .b: return .variantB
        }
    }
}
