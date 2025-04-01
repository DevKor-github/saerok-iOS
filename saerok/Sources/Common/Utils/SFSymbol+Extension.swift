//
//  SFSymbol.swift
//  saerok
//
//  Created by HanSeung on 3/27/25.
//

import SwiftUI

enum SFSymbol: String {
    case ellipsis
    case ellipsisMessage = "ellipsis.message"
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case chevronDown = "chevron.down"
    case chevronUp = "chevron.up"
    case magnifyingglass
    case bell
    case house
    case person
    case heart
    case book
}

extension Image {
    init(_ name: SFSymbol) {
        self.init(systemName: name.rawValue)
    }
}
