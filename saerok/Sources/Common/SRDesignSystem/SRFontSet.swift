//
//  SRFontSet.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUICore

extension Font {
    enum SRFontSet {
        static let button: Font = .custom(Pretendard.bold.rawValue, size: 18.0)

        static let tabbar: Font = .custom(Pretendard.regular.rawValue, size: 11).weight(.regular)
        static let tabbarSelected: Font = .custom(Pretendard.medium.rawValue, size: 11).bold()

        static let headline1: Font = .custom(Moneygraphy.rounded.rawValue, size: 30)
        static let headline2: Font = .custom(Moneygraphy.rounded.rawValue, size: 22)
        
        static let subtitle1: Font = .custom(Moneygraphy.rounded.rawValue, size: 20)
        static let subtitle2: Font = .custom(Moneygraphy.rounded.rawValue, size: 18)
        static let subtitle3: Font = .custom(Pretendard.regular.rawValue, size: 18)
        
        static let body0: Font = .custom(Pretendard.bold.rawValue, size: 16)
        static let body1: Font = .custom(Pretendard.semiBold.rawValue, size: 15)
        static let body2: Font = .custom(Pretendard.regular.rawValue, size: 15)
        static let body3: Font = .custom(Moneygraphy.rounded.rawValue, size: 15)
        
        static let caption1: Font = .custom(Pretendard.regular.rawValue, size: 13)
        static let caption2: Font = .custom(Moneygraphy.rounded.rawValue, size: 13)
        static let caption3: Font = .custom(Pretendard.regular.rawValue, size: 12)
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

enum Moneygraphy: String, CaseIterable {
    case rounded = "MoneygraphyTTF-Rounded"
}
