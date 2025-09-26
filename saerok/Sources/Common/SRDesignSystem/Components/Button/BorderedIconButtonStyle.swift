//
//  BorderedIconButtonStyle.swift
//  saerok
//
//  Created by HanSeung on 9/24/25.
//


import SwiftUI

struct BorderedIconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle().fill(.glassWhite)
                    .frame(width: 40, height: 40)
            )
            .frame(width: 40, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .inset(by: 0.5)
                    .stroke(.srLightGray, lineWidth: 1)
                
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == BorderedIconButtonStyle {
    static var borderedIcon: Self { Self() }
}
