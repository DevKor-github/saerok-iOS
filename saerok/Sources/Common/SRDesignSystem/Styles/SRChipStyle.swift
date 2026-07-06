//
//  SRChipStyle.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 캡슐 칩 스타일: 상하/좌우 패딩 + 배경 + 무한 코너.
struct SRChipStyle: ViewModifier {
    let background: Color
    var horizontalPadding: CGFloat = 15
    var verticalPadding: CGFloat = 9

    func body(content: Content) -> some View {
        content
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(background)
            .cornerRadius(.infinity)
    }
}
