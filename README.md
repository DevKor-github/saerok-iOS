# 새록(saerok-iOS)

> **“새를 기록하다, 새록”** — 관찰한 새를 사진·위치·메모로 기록하고 지도로 탐색하는 iOS 앱.

---

## 주요 기능
- 새 관찰 기록: 사진, 위치, 메모 저장
- 도감 기능: 새 목록 검색·상세 보기
- 지도 탐색: 커스텀 마커·클러스터링
- 소셜 로그인: Apple, Kakao
- 이미지 업로드
- 알림/분석

---

## 기술 스택
- **언어**: Swift (iOS 17+)
- **UI**: SwiftUI, Custom Components (TabBar, BottomSheet 등)
- **상태 관리**: AppState (EnvironmentObject), DIContainer
- **아키텍처**: Clean Architecture (Presentation / Business / Data)
- **네트워크**: URLSession, Repository, DTO ↔ Domain 매핑
- **지도**: Naver Maps iOS SDK, Kakao Geocoding API
- **인증**: Sign in with Apple, Kakao SDK
- **보안**: Keychain (JWT/토큰 관리)
- **업로드**: AWS S3 Presigned URL
- **알림/분석**: APNs, Amplitude Analytics

---

## 아키텍처 개요
```
View (SwiftUI)
  ↓ Action
Interactor (Business)
  ↓ Domain
Repository (Data)
  ↓ Network/Local
```
- **View**: SwiftUI 상태 관리 + 사용자 입력 전달
- **Interactor**: 도메인 규칙, 상태 변환
- **Repository**: API/로컬 접근, DTO 매핑
- **DI**: `DIContainer`를 Environment(`\.injected`) 또는 생성자 주입

---

## 폴더 구조
```
Application/   # AppState, DI, Routing
Common/        # DesignSystem, Utils, Extensions
Core/          # Network, Cache, Keychain, Uploader
Data/          # DTO, Repository, Local Models
Features/      # FieldGuide, Collection, Map, Login, MyPage
Resources/     # Assets, Strings, Config
```

