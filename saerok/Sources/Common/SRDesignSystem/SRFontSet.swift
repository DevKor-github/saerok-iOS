//
//  SRFontSet.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUICore

extension Font {
    enum SRFontSet {
        static let h1: Font = .custom(Pretendard.semiBold.rawValue, size: 24.0)
        static let h2: Font = .custom(Pretendard.semiBold.rawValue, size: 20.0)
        static let h3: Font = .custom(Pretendard.medium.rawValue, size: 15.0)
        static let h4: Font = .custom(Pretendard.regular.rawValue, size: 13.0)

        static let tabbar: Font = .custom(Pretendard.regular.rawValue, size: 11).weight(.regular)
        static let tabbarSelected: Font = .custom(Pretendard.medium.rawValue, size: 11).bold()
    }
}

enum Pretendard: String, CaseIterable {
    case black = "PretendardVariable-Black"
    case thin = "PretendardVariable-Thin"
    case semiBold = "PretendardVariable-SemiBold"
    case light = "PretendardVariable-Light"
    case extraLight = "PretendardVariable-ExtraLight"
    case regular = "PretendardVariable-Regular"
    case medium = "PretendardVariable-Medium"
    case bold = "PretendardVariable-Bold"
}

