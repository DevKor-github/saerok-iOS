//
//  SRFontSet.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUI

/// 폰트 토큰.
///
/// 접미사 규칙: `_2`/`_3`/`_4`는 **같은 사이즈 슬롯의 서체·웨이트 변형**이다.
extension Font {
    enum SRFontSet {
        static let button: Font = .custom(Pretendard.bold.rawValue, size: 18.0)

        static let tabbar: Font = .custom(Pretendard.regular.rawValue, size: 11).weight(.regular)
        static let tabbarSelected: Font = .custom(Pretendard.medium.rawValue, size: 11).bold()

        static let headline1: Font = .custom(Jalpullineunharu.regular.rawValue, size: 30)
        static let headline2: Font = .custom(Jalpullineunharu.regular.rawValue, size: 22)
        static let headline2_2: Font = .custom(Moneygraphy.regular.rawValue, size: 22)
        static let headline2_3: Font = .custom(Pretendard.semiBold.rawValue, size: 22)

        static let subtitle1: Font = .custom(Moneygraphy.regular.rawValue, size: 20)
        static let subtitle2: Font = .custom(Jalpullineunharu.regular.rawValue, size: 18)
        static let subtitle3: Font = .custom(Pretendard.regular.rawValue, size: 18)
        static let subtitle1_2: Font = .custom(Jalpullineunharu.regular.rawValue, size: 20)
        static let subtitle1_3: Font = .custom(Pretendard.bold.rawValue, size: 20)
        static let subtitle1_4: Font = .custom(Pretendard.regular.rawValue, size: 20)

        static let body0: Font = .custom(Pretendard.bold.rawValue, size: 16)
        static let body1: Font = .custom(Pretendard.regular.rawValue, size: 15)
        static let body2: Font = body1          // 중복 정의 — 삭제 후보
        static let body2_2: Font = body1        // 중복 정의 — 삭제 후보
        static let body2_3: Font = .custom(Pretendard.semiBold.rawValue, size: 15)
        static let body3: Font = .custom(Moneygraphy.regular.rawValue, size: 15)
        static let body3_2: Font = .custom(Jalpullineunharu.regular.rawValue, size: 15)
        static let body4: Font = .custom(Pretendard.regular.rawValue, size: 14)
        static let body4_2: Font = body1        // 중복 정의 — 삭제 후보
        static let body4_3: Font = .custom(Pretendard.semiBold.rawValue, size: 15)

        static let caption0: Font = .custom(Pretendard.bold.rawValue, size: 13)
        static let caption1: Font = .custom(Pretendard.regular.rawValue, size: 13)
        static let caption1_2: Font = caption1  // 중복 정의 — 삭제 후보

        static let caption2: Font = .custom(Moneygraphy.regular.rawValue, size: 13)
        static let caption3: Font = .custom(Pretendard.regular.rawValue, size: 12)
        static let caption3_2: Font = .custom(Pretendard.bold.rawValue, size: 12)
        
        static let button1: Font = button       // 중복 정의 — 삭제 후보
        static let button1_2: Font = .custom(Pretendard.medium.rawValue, size: 18)
        static let button2: Font = .custom(Pretendard.semiBold.rawValue, size: 15)
        static let button3: Font = .custom(Pretendard.bold.rawValue, size: 13)

        static let heavy: Font = .custom(Pretendard.semiBold.rawValue, size: 40)
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

enum Jalpullineunharu: String, CaseIterable {
    case regular = "JalpullineunharuM"
}

enum Moneygraphy: String, CaseIterable {
    case regular = "MoneygraphyTTF-Rounded"
}
