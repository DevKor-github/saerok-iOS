//
//  IconButtonStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

struct IconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle().fill(.glassWhite)
                    .frame(width: 40, height: 40)
            )
            .frame(width: 40, height: 40)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == IconButtonStyle {
    static var icon: Self { Self() }
}
