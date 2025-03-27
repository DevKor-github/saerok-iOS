//
//  SRComponentStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

enum SRComponentStyle {
    case textField(isFocused: FocusState<Bool>.Binding)
    case defaultItem

    @MainActor @ViewBuilder
    func apply(to view: some View) -> some View {
        switch self {
        case .textField(let isFocused):
            view.modifier(SRTextFieldStyle(isFocused: isFocused))
        case .defaultItem:
            view.modifier(DefaultItemStyle())
        }
    }
}

extension View {
    func srStyled(_ style: SRComponentStyle) -> some View {
        style.apply(to: self)
    }
}

