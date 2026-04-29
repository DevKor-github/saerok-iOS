# 새록 (Saerok)

> **"새를 기록하다, 새록"**  
> 탐조(Birdwatching) 기록을 위한 iOS 앱 — 관찰한 새를 사진·위치·메모와 함께 기록하고, 도감과 지도로 탐색합니다.

---

## 주요 기능

| 기능 | 설명 |
|------|------|
| **관찰 기록** | 새 이름, 사진, 위치, 날짜, 메모를 함께 기록 |
| **새 도감** | 이름 검색, 상세 정보·사진 조회, SwiftData 로컬 캐시 |
| **지도 탐색** | 관찰 위치 시각화, 커스텀 마커 클러스터링 (Naver Maps) |
| **컬렉션** | 개인 관찰 기록 목록 관리, 댓글·좋아요 기능 |
| **커뮤니티** | 다른 탐조인들의 기록 탐색 및 소통 |
| **마이페이지** | 프로필 관리, 알림, 계정 설정 |
| **소셜 로그인** | Apple 로그인, Kakao 로그인 지원 |

---

## 기술 스택

### Language & Platform
- Swift 5.9+ / iOS 17+

### UI & Architecture
- **SwiftUI** + Custom Design System (`SRDesignSystem`)
- **Clean Architecture**: `View → ViewModel → Interactor → Repository → Network`
- **`@Observable`** macro 기반 상태 관리 (`ObservableObject` / `@Published` 미사용)
- **`LoadState<T>`** 비동기 상태 패턴

### Networking & Data
- `URLSession` 기반 커스텀 네트워크 레이어 (`SRNetworkService`)
- Endpoint 정의 + DTO → Domain Model 변환
- **SwiftData** — 도감(Field Guide) 로컬 캐시
- **Keychain** — JWT 토큰 보안 저장

### 외부 SDK / 서비스
| 분류 | 사용 기술 |
|------|----------|
| 지도 | Naver Maps iOS SDK |
| 주소 변환 | Kakao Geocoding API |
| 인증 | Sign in with Apple, Kakao Login |
| 이미지 업로드 | AWS S3 Presigned URL |
| 분석 | Amplitude Analytics |

---

## 아키텍처

```
┌─────────────────────────────────────────────────────┐
│  SwiftUI View  (@Observable ViewModel)               │
│    └─ Output enum → AppCoordinator (Navigation)      │
├─────────────────────────────────────────────────────┤
│  Interactor  (비즈니스 로직 / Use Case)               │
├─────────────────────────────────────────────────────┤
│  Repository  (데이터 접근 / DTO → Domain 변환)        │
├─────────────────────────────────────────────────────┤
│  NetworkService / SwiftData  (API 통신 / 로컬 캐시)   │
└─────────────────────────────────────────────────────┘
```

- **`AppCoordinator`**: 모든 ViewModel 인스턴스를 factory 메서드로 생성, `NavigationPath` 기반 라우팅
- **`DIContainer`**: 의존성 그래프 조립 (Repository → Interactor → ViewModel 순)
- **`CancelBag`**: Combine 구독 생명주기 관리
- **`Store<AppState>`**: 전역 앱 상태 (인증 정보 등) 

---

## 프로젝트 구조

```
saerok/Sources/
├── App/
│   ├── Dependency/          # DIContainer, AppEnvironment
│   ├── AppCoordinator.swift # 네비게이션 + ViewModel 팩토리
│   ├── AppState.swift
│   └── PushNotificationManager.swift
│
├── Common/
│   ├── SRDesignSystem/      # 디자인 시스템 컴포넌트 및 스타일
│   ├── Utils/               # Extensions, ImageLoader, Helper
│   └── ...                  # Loadable, Store, CancelBag, KeyChain
│
├── Feature/
│   ├── Collection/          # 개인 관찰 기록
│   ├── Community/           # 커뮤니티
│   ├── FieldGuide/          # 새 도감
│   ├── Login/               # 소셜 로그인
│   ├── Map/                 # 지도 탐색
│   ├── MyPage/              # 마이페이지
│   ├── Onboarding/
│   └── Root/
│
├── Interactors/             # 비즈니스 로직 레이어
│   ├── CollectionInteractor.swift
│   ├── CommunityInteractor.swift
│   ├── FieldGuideInteractor.swift
│   ├── MapInteractor.swift
│   └── UserInteractor.swift
│
├── Repositories/            # 데이터 접근 레이어
│   ├── BirdsRepository.swift
│   ├── CollectionRepository.swift
│   ├── CommunityRepository.swift
│   ├── MapRepository.swift
│   └── UserRepository.swift
│
└── Network/                 # API 통신 레이어
    ├── APIClient
    ├── Endpoints
    └── NetworkService
```

각 Feature는 `View/` + `ViewModel/` 구조를 따르며, ViewModel은 `extension FeatureView { @Observable final class ViewModel }` 형태로 정의합니다.

---

## 개발 환경

- Xcode 15+
- iOS 17+
- Swift 5.9+

---

## License

This project is developed for the **apu** team.
