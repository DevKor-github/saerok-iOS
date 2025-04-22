//
//  FilterButtonStyle.swift
//  saerok
//
//  Created by HanSeung on 4/15/25.
//


import SwiftUI
 
struct FilterButtonStyle: ButtonStyle {
    var isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isActive ? .main : Color.background)
            .foregroundStyle(isActive ? .srWhite : .primary)
            .clipShape(RoundedRectangle(cornerRadius: .infinity))
//            .shadow(color: .border, radius: 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
