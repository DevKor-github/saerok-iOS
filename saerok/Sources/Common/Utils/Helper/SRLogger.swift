//
//  SRLogger.swift
//  saerok
//
//  통합 로깅 진입점. `print` 대신 `os.Logger`를 카테고리별로 래핑한다.
//
//  - subsystem 은 번들 식별자(dev/prod 분리)를 그대로 사용하므로
//    Console.app 에서 환경별로 자동 분리되어 보인다.
//  - 카테고리로 필터링: `subsystem:com.apu.saerok category:network` 등.
//  - 레벨 가이드:
//      .debug  개발 중 상세 추적 (릴리스에서 기본 비활성·비영속)
//      .info   일반 흐름
//      .error  실패 — 운영에서도 관찰 가치 있는 것 (Console·sysdiagnose 영속)
//      .fault  버그/위반 (회복 불가에 가까운 상태)
//
//  민감 데이터: 문자열 보간은 기본적으로 릴리스에서 redacted 된다.
//  값을 노출하려면 명시적으로 `privacy: .public` 을 지정한다.
//  (토큰·비밀번호 등은 절대 `.public` 으로 찍지 않는다.)
//

import Foundation
import os

enum SRLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.apu.saerok"

    /// 네트워크 요청/응답
    static let network = Logger(subsystem: subsystem, category: "network")
    /// 인증·세션·토큰 갱신
    static let auth = Logger(subsystem: subsystem, category: "auth")
    /// 푸시 알림·APNs·FCM
    static let push = Logger(subsystem: subsystem, category: "push")
    /// 딥링크 라우팅
    static let deeplink = Logger(subsystem: subsystem, category: "deeplink")
    /// 그 외 일반 앱 흐름
    static let app = Logger(subsystem: subsystem, category: "app")
}
