//
//  SRFloatingButtonStyle.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 플로팅 원형 버튼 이미지 스타일: 고정 프레임 + 그림자.
struct SRFloatingButtonStyle: ViewModifier {
    var size: CGFloat = 61
    var shadow: SRShadow = .floating25

    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .srShadow(shadow)
    }
}
