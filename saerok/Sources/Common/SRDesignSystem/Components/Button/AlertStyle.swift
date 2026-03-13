//
//  AlertStyle.swift
//  saerok
//
//  Created by HanSeung on 6/18/25.
//


import SwiftUI

enum AlertStyle {
    case confirm
    case delete
    case bordered
    
    struct ComfirmButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) private var isEnabled

        var defaultColor: Color = .main
        var pressedColor: Color = .main.opacity(0.7)
        var disabledColor: Color = .border

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.SRFontSet.button2)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity)
                .background(isEnabled ? (configuration.isPressed ? pressedColor : defaultColor) : disabledColor)
                .foregroundColor(.srWhite)
                .cornerRadius(15)
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
                .font(.SRFontSet.button2)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity)
                .foregroundColor(.red)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .inset(by: 0.75)
                        .stroke(.red, lineWidth: 1.5)
                )
                .cornerRadius(15)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .contentShape(Rectangle())
        }
    }

    struct BorderedButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) private var isEnabled

        var defaultColor: Color = .main
        var pressedColor: Color = .main
        var disabledColor: Color = .main

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.SRFontSet.button2)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity)
                .foregroundColor(defaultColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .inset(by: 0.75)
                        .stroke(defaultColor, lineWidth: 1.5)
                )
                .cornerRadius(15)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .contentShape(Rectangle())
        }
    }

}

extension ButtonStyle where Self == AlertStyle.ComfirmButtonStyle {
    static var alert_confirm: Self { Self() }
}

extension ButtonStyle where Self == AlertStyle.DeleteButtonStyle {
    static var alert_delete: Self { Self() }
}

extension ButtonStyle where Self == AlertStyle.BorderedButtonStyle {
    static var alert_bordered: Self { Self() }
}
