//
//  PrimaryButtonStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var defaultColor: Color = .main
    var pressedColor: Color = .main.opacity(0.7)
    var disabledColor: Color = .border

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.SRFontSet.button1)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? (configuration.isPressed ? pressedColor : defaultColor) : disabledColor)
            .foregroundColor(.srWhite)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: Self { Self() }
}





