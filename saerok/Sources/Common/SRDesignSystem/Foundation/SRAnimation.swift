//
//  SRAnimation.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 애니메이션 토큰.
enum SRAnimation {
    /// easeInOut(duration: 0.2) — 인터랙션 피드백
    static let easeInOut20 = Animation.easeInOut(duration: 0.2)
    /// easeInOut(duration: 0.25) — 오버레이 전환
    static let easeInOut25 = Animation.easeInOut(duration: 0.25)
    /// easeInOut(duration: 0.35)
    static let easeInOut35 = Animation.easeInOut(duration: 0.35)
    /// spring(response: 0.35, dampingFraction: 0.9) — 플로팅 메뉴
    static let spring35_90 = Animation.spring(response: 0.35, dampingFraction: 0.9)
}
