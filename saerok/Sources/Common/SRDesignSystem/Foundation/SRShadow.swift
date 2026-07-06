//
//  SRShadow.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 그림자 토큰.
///
/// 1회성 조합은 호출부에서 `.black(0.07, radius: 6, y: 2)` 처럼 인라인으로 생성해 값이 그대로 드러나게 한다.
struct SRShadow: Equatable {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    /// 검정 기반 그림자 팩토리
    static func black(_ opacity: Double, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> SRShadow {
        .init(color: Color.black.opacity(opacity), radius: radius, x: x, y: y)
    }

    /// 카드 그림자 최빈값 — (0.1, r5, y0)
    static let card10 = SRShadow.black(0.1, radius: 5)
    /// 플로팅 원형 버튼 — (0.25, r5, y0)
    static let floating25 = SRShadow.black(0.25, radius: 5)
    /// 흰 원형 아이콘 칩 — (0.1, r5, y2)
    static let chipIcon10 = SRShadow.black(0.1, radius: 5, y: 2)
}

extension View {
    func srShadow(_ shadow: SRShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    /// nil이면 그림자를 적용하지 않는다 (옵셔널 파라미터용 no-op 오버로드)
    @ViewBuilder
    func srShadow(_ shadow: SRShadow?) -> some View {
        if let shadow {
            self.srShadow(shadow)
        } else {
            self
        }
    }
}
