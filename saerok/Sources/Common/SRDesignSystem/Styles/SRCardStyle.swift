//
//  SRCardStyle.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 카드 스타일: 배경 + 코너 라디우스 + (옵션) 테두리 + (옵션) 그림자.
struct SRCardStyle: ViewModifier {
    var radius: CGFloat = SRRadius.card
    var background: Color = .srWhite
    var shadow: SRShadow? = .card10
    var strokeColor: Color? = nil
    var strokeWidth: CGFloat = 1
    var strokeInset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .background(background)
            .cornerRadius(radius)
            .overlay {
                if let strokeColor {
                    RoundedRectangle(cornerRadius: radius)
                        .inset(by: strokeInset)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                }
            }
            .srShadow(shadow)
    }
}
