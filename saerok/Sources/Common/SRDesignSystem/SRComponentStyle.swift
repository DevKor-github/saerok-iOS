//
//  SRComponentStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

enum SRComponentStyle {
    case textField(isFocused: FocusState<Bool>.Binding, alwaysFocused: Bool = false)
    case filterButton(isActive: Bool, isResetButton: Bool = false)
    case defaultItem
    case iconButton

    @MainActor @ViewBuilder
    func apply(to view: some View) -> some View {
        switch self {
        case .textField(let isFocused, let alwaysFocused):
            view.modifier(SRTextFieldStyle(isFocused: isFocused, alwaysFocused: alwaysFocused))
        case .filterButton(let isActive, let isResetButton):
            view.buttonStyle(FilterButtonStyle(isActive: isActive, isResetButton: isResetButton))
        case .defaultItem:
            view.modifier(DefaultItemStyle())
        case .iconButton:
            view.buttonStyle(.icon)
        }
    }
}

extension View {
    func srStyled(_ style: SRComponentStyle) -> some View {
        style.apply(to: self)
    }
}

