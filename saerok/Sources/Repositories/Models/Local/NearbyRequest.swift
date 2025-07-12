//
//  NearbyRequest.swift
//  saerok
//
//  Created by HanSeung on 6/9/25.
//

extension Local {
    struct NearbyRequest {
        let latitude: Double
        let longtitude: Double
        let radius: Double
        let isMineOnly: Bool
        let isGuest: Bool
    }
}
