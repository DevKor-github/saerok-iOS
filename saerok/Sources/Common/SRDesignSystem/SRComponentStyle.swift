//
//  SRComponentStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

enum SRComponentStyle {
    case textField(isFocused: FocusState<Bool>.Binding, alwaysFocused: Bool = false, tintColor: Color? = nil)
    case filterButton(isActive: Bool, isResetButton: Bool = false)
    case defaultItem
    case primaryButton
    case iconButton
    case borderedIconButton
    case avatar
    case alert(_ type: AlertStyle)

    @MainActor @ViewBuilder
    func apply(to view: some View) -> some View {
        switch self {
        case .textField(let isFocused, let alwaysFocused, let tintColor):
            view.modifier(SRTextFieldStyle(isFocused: isFocused, alwaysFocused: alwaysFocused, tintColor: tintColor ?? .main))
        case .filterButton(let isActive, let isResetButton):
            view.buttonStyle(FilterButtonStyle(isActive: isActive, isResetButton: isResetButton))
        case .defaultItem:
            view.modifier(DefaultItemStyle())
        case .iconButton:
            view.buttonStyle(.icon)
        case .borderedIconButton:
            view.buttonStyle(.borderedIcon)
        case .avatar:
            view.srAvatarStyle()
        case .primaryButton:
            view.buttonStyle(.primary)
        case .alert(.confirm):
            view.buttonStyle(.alert_confirm)
        case .alert(.delete):
            view.buttonStyle(.alert_delete)
        case .alert(.bordered):
            view.buttonStyle(.alert_bordered)
        }
    }
}

extension View {
    func srStyled(_ style: SRComponentStyle) -> some View {
        style.apply(to: self)
    }
}

