//
//  SecondaryButtonStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    var defaultColor: Color = .blue.opacity(0.3)
    var pressedColor: Color = .blue
    var disabledColor: Color = Color.srGray
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isEnabled ? (configuration.isPressed ? pressedColor : defaultColor) : disabledColor)
            .foregroundColor(isEnabled ? .black : Color.srGray)
            .cornerRadius(SRDesignConstant.cornerRadius)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.5)
            .overlay(
                RoundedRectangle(cornerRadius: SRDesignConstant.cornerRadius)
                    .stroke(Color.white, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: Self { Self() }
}
