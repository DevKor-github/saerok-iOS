//
//  LinearGradient+Extension.swift
//  saerok
//
//  Created by HanSeung on 5/6/25.
//


import SwiftUI

extension LinearGradient {
    static let birdCardBackground = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: .clear, location: 0.0),
            .init(color: .grdiendMid.opacity(0.9), location: 0.82),
            .init(color: .white, location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}
