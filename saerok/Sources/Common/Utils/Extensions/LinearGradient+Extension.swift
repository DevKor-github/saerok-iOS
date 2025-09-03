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
    
    static let collectionBackground: LinearGradient = .init(
        stops: [
            Gradient.Stop(color: Color(red: 0.97, green: 0.97, blue: 0.97), location: 0.00),
            Gradient.Stop(color: Color(red: 0.97, green: 0.97, blue: 0.97), location: 0.95),
            Gradient.Stop(color: Color(red: 0.97, green: 0.97, blue: 0.97).opacity(0), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.5, y: 1),
        endPoint: UnitPoint(x: 0.5, y: 0)
    )
}
