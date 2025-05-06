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
            .padding(.vertical, 8)
            .background(isActive ? .main : Color.whiteGray)
            .foregroundStyle(isActive ? .srWhite : .primary)
            .clipShape(RoundedRectangle(cornerRadius: .infinity))
            .overlay {
                RoundedRectangle(cornerRadius: .infinity)
                    .stroke(isActive ? Color.main : Color.gray, lineWidth: 0.35)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
