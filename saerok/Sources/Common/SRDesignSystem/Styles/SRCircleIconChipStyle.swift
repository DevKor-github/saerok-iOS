//
//  SRCircleIconChipStyle.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 원형 아이콘 칩: 아이콘 뒤에 붙는 흰 원 + 그림자 배경.
struct SRCircleIconChipStyle: ViewModifier {
    var fill: Color = .white
    var shadow: SRShadow? = .chipIcon10

    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(fill)
                    .srShadow(shadow)
            )
    }
}
