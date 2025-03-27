//
//  PrimaryButtonStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var defaultColor: Color = .blue.opacity(0.6)
    var pressedColor: Color = .blue
    var disabledColor: Color = .gray

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isEnabled ? (configuration.isPressed ? pressedColor : defaultColor) : disabledColor)
            .foregroundColor(isEnabled ? .black : .gray)
            .cornerRadius(SRDesignConstant.cornerRadius)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: Self { Self() }
}
