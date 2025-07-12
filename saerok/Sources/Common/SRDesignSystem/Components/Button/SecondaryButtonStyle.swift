//
//  SecondaryButtonStyle.swift
//  saerok
//
//  Created by HanSeung on 6/18/25.
//


import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var defaultColor: Color = .primary
    var pressedColor: Color = .primary
    var disabledColor: Color = .primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.SRFontSet.subtitle3)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .foregroundColor(defaultColor)
            .background(Color.clear)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: Self { Self() }
}
