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
    var pressedColor: Color = .main
    var disabledColor: Color = .border

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.SRFontSet.body1)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? (configuration.isPressed ? pressedColor : defaultColor) : disabledColor)
            .foregroundColor(.srWhite)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .contentShape(Rectangle())
    }
}

struct DeleteButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var defaultColor: Color = .red
    var pressedColor: Color = .red
    var disabledColor: Color = .red

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.SRFontSet.body1)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .foregroundColor(.red)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.75)
                    .stroke(.red, lineWidth: 1.5)
            )
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .contentShape(Rectangle())
    }
}

struct NormalButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var defaultColor: Color = .main
    var pressedColor: Color = .main
    var disabledColor: Color = .main

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.SRFontSet.body1)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .foregroundColor(defaultColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.75)
                    .stroke(defaultColor, lineWidth: 1.5)
            )
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: Self { Self() }
}


extension ButtonStyle where Self == DeleteButtonStyle {
    static var delete: Self { Self() }
}

extension ButtonStyle where Self == NormalButtonStyle {
    static var normal: Self { Self() }
}
