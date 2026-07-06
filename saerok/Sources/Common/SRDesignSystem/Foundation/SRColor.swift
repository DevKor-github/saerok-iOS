//
//  SRColor.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 색상 토큰 문서.
///
/// 색상은 Asset Catalog(`Resources/Assets.xcassets/colorSet/`)에 정의되며,
/// Xcode 자동 생성 심볼로 접근한다 (에셋명 끝의 "Color" 접미사는 심볼에서 제거됨: MainColor → `.main`).
/// 이 파일은 코드가 아닌 **의미 매핑 문서**다. 에셋 rename은 리스크가 커서 이번 라운드에서 하지 않는다.
///
/// | 심볼 | 에셋 | 관측된 용도 |
/// |------|------|------------|
/// | `.main` | MainColor | 브랜드 프라이머리 (#92C0FF). CTA·활성 상태 전용 |
/// | `.mainLight` | MainLightColor | 프라이머리 연한 변형 |
/// | `.srWhite` | SRWhite | 컨텐츠·카드 배경 |
/// | `.srGray` | SRGray | 보조 텍스트·아이콘 |
/// | `.srLightGray` | SRLightGray | 테두리, 비활성 배경, 아바타 스트로크 |
/// | `.srDarkGray` | srDarkGray | 진한 보조 텍스트 |
/// | `.border` | BorderColor | 텍스트필드 등 외곽선 |
/// | `.whiteGray` | whiteGray | 시트 인디케이터, 연한 스트로크 (SRWhite와 별개 값) |
/// | `.splash` | splash | 액센트·칩 배경 |
/// | `.glassWhite` | GlassWhite | 아이콘 버튼 배경 |
/// | `.point` / `.pointLight` | Point / PointLight | 포인트 강조 |
/// | `.pointtext` | pointtext | 포인트 텍스트 (에셋명 오타 아님 확인 필요 — 알려진 부채) |
/// | `.fire` | fire | 에러·경고 |
/// | `.iconRed` / `.lightRed` | iconRed / lightRed | 빨강 계열 아이콘·배경 |
/// | `.kakao` | kakao | 카카오 로그인 브랜딩 |
/// | `.srGreen` | srGreen | 성공 계열 |
/// | `.srGradientstart` / `.grdiendMid` / `.srGradientEnd` | 〃 | 그라데이션 3스톱 (grdiendMid는 오타 에셋 — 알려진 부채, rename 보류) |
/// | `.srDivider92` | srDivider92 | 셀 선택 상태 회색 (0.92,0.92,0.92) — 구 RGB 하드코딩 대체 |
/// | `.srInputBorder` | srInputBorder | 댓글 입력바 스트로크 (0.85,0.88,0.87) — 구 RGB 하드코딩 대체 |
/// | `.srGray59` | srGray59 | 이미지 placeholder 배경 (0.59,0.59,0.59) — 구 RGB 하드코딩 대체 |
///
/// 규칙:
/// - Feature 코드에서 hex·RGB 리터럴 금지. 필요한 색이 없으면 colorset을 추가한다.
/// - `Color.black.opacity(...)` 그림자는 `SRShadow` 토큰을 통해 사용한다.
enum SRColorDoc {}
