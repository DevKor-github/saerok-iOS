//
//  SRFontSet.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUICore

extension Font {
    enum SRFontSet {
        static let h1: Font = .custom(Pretendard.regular.rawValue, size: 24.0).weight(.semibold)
    }
}

enum Pretendard: String, CaseIterable {
    case regular = "Pretendard-Regular"
    case medium = "Pretendard-Medium"
    case bold = "Pretendard-Bold"
}

