//
//  SFSymbol.swift
//  saerok
//
//  Created by HanSeung on 3/27/25.
//

import SwiftUI

enum SFSymbol: String {
    case ellipsis
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case chevronDown = "chevron.down"
    case chevronUp = "chevron.up"
}

extension Image {
    init(_ name: SFSymbol) {
        self.init(systemName: name.rawValue)
    }
}
