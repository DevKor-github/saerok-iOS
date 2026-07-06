//
//  SRRadius.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 코너 라디우스 토큰.
///
/// 산발적으로 쓰이는 값(12/15/17 등)은 의미가 확정되기 전까지 토큰화하지 않고 호출부 리터럴을 유지한다.
enum SRRadius {
    /// 시트·대형 컨테이너
    static let sheet: CGFloat = 24
    /// 카드
    static let card: CGFloat = 20
    /// 소형 아이템·셀
    static let item: CGFloat = 10
}
