//
//  SRAvatarStyle.swift
//  saerok
//
//  Created by HanSeung on 3/10/26.
//

import SwiftUI

/// 아바타(프로필 이미지) 스타일: 고정 프레임 + 원형 클리핑 + (옵션) 스트로크.
struct SRAvatarStyle: ViewModifier {
    var size: CGFloat = 25
    var strokeColor: Color = .srLightGray
    var strokeWidth: CGFloat = 2
    var strokeInset: CGFloat = 0.6

    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay {
                if strokeWidth > 0 {
                    Circle()
                        .inset(by: strokeInset)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                }
            }
    }
}
