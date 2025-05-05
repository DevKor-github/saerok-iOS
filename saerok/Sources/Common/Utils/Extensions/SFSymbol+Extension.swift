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
    case bookmark
    case bookmarkFill = "bookmark.fill"
    case calendar
    case tree
    case xmarkCircleFill = "xmark.circle.fill"
}

extension Image {
    init(_ name: SFSymbol) {
        self.init(systemName: name.rawValue)
    }
}
