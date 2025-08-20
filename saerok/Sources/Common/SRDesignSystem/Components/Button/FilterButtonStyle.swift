//
//  FilterButtonStyle.swift
//  saerok
//
//  Created by HanSeung on 4/15/25.
//


import SwiftUI
 
struct FilterButtonStyle: ButtonStyle {
    var isActive: Bool
    let isResetButton: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.leading, isResetButton ? 9 : 12)
            .padding(.trailing, isResetButton ? 9 : 15)
            .padding(.vertical, isResetButton ? 9 : 9)
            .background(isActive ? .main : Color.srWhite)
            .foregroundStyle(isActive ? .srWhite : .primary)
            .clipShape(RoundedRectangle(cornerRadius: .infinity))
            .overlay {
                RoundedRectangle(cornerRadius: .infinity)
                    .stroke(isActive ? Color.main : Color.srGray, lineWidth: 0.35)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
