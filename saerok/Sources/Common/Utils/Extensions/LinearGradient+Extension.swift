//
//  LinearGradient+Extension.swift
//  saerok
//
//  Created by HanSeung on 5/6/25.
//


import SwiftUI

extension LinearGradient {
    static let birdCardBackground: LinearGradient = .init(
        gradient: Gradient(stops: [
            .init(color: .clear, location: 0.0),
            .init(color: .grdiendMid.opacity(0.9), location: 0.82),
            .init(color: .white, location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let srGradient: LinearGradient = .init(
        gradient: Gradient(stops: [
            .init(color: .srGradientstart, location: 0.0),
            .init(color: .srGradientEnd, location: 0.84),
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
}
