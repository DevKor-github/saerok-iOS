# 새록 (Saerok)

> **"새를 기록하다, 새록"**  
> 탐조(Birdwatching) 기록을 위한 iOS 앱 — 관찰한 새를 사진·위치·메모와 함께 기록하고, 도감과 지도로 탐색하며, 커뮤니티에서 소통합니다.

---

## 주요 기능

| 기능 | 설명 |
|------|------|
| **관찰 기록** | 새 이름, 사진, 위치, 날짜, 메모를 함께 기록 (S3 Presigned URL 이미지 업로드) |
| **새 도감** | 이름 검색, 상세 정보·사진 조회, 북마크, SwiftData 로컬 캐시 |
| **지도 탐색** | 관찰 위치 시각화, 커스텀 마커 클러스터링 (Naver Maps) |
| **컬렉션** | 개인 관찰 기록 목록 관리, 댓글·좋아요 |
| **커뮤니티** | 자유게시판 (게시글 작성·댓글·신고), 동정의견 요청 및 채택 |
| **알림** | FCM 푸시 알림, 딥링크 (게시글·기록·운영팀 메시지), 알림 설정 |
| **마이페이지** | 프로필 관리, 공지사항, 계정 설정 |
| **소셜 로그인** | Sign in with Apple, Kakao 로그인 (게스트 모드 지원) |

---

## 기술 스택

### Language & Platform
- Swift 5.9+ / iOS 17.6+ / Xcode 16+

### UI & Architecture
- **SwiftUI** + Custom Design System (`SRDesignSystem`)
- **Clean Architecture**: `View → ViewModel → Interactor → Repository → Network/SwiftData`
- **`@Observable`** macro 기반 ViewModel (`ObservableObject` / `@Published` 미사용)
- **`LoadState<T>`** 비동기 로딩 상태 패턴
- **`AppStore`** 전역 상태 — 상태(`Store<AppState>`) + 일회성 이벤트(`AppEvent`) 2채널, `send(AppAction)` 단방향 변경

### Networking & Data
- `URLSession` 기반 커스텀 네트워크 레이어 (`SRNetworkService`, Alamofire 미사용)
- `SREndpoint` struct factory 패턴 — 도메인별 extension 파일로 분리
- 401 응답 시 자동 토큰 갱신 및 세션 만료 처리
- **SwiftData** — 도감(Field Guide) 로컬 캐시
- **Keychain** — JWT 토큰 보안 저장

### 외부 SDK / 서비스
| 분류 | 사용 기술 |
|------|----------|
| 지도 | Naver Maps iOS SDK |
| 주소 변환 | Kakao Geocoding API |
| 인증 | Sign in with Apple, Kakao Login |
| 푸시·원격 설정 | Firebase (FCM, Remote Config) — dev/production 환경 분리 |
| 이미지 업로드 | AWS S3 Presigned URL |
| 분석 | Amplitude Analytics |
| 광고 | Kakao AdFit |
| 애니메이션 | Lottie |

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

- **`AppStore`**: 전역 상태 2채널 — 영속 상태는 `updates(for:)` 구독, 일회성 이벤트(탭 간 화면 전환 등)는 `events` 구독. 변경은 `send(AppAction)` 단방향으로만
- **`AppCoordinator`**: `NavigationPath` 기반 라우팅, 탭 루트 ViewModel 캐싱 (로그아웃 시 reset)
- **`ViewModelFactory`**: ViewModel 생성 전담 — View에서 직접 생성하지 않음
- **`DIContainer`**: 의존성 그래프 조립 (Repository → Interactor 순), `@Environment`로 주입
- **`CancelBag`**: Combine 구독 생명주기 관리

자세한 작성 규칙은 개발 가이드 문서 참고:
- [ARCHITECTURE](docs/ARCHITECTURE.md) — 전체 구조 및 계층 설명
- [VIEW-GUIDE](docs/VIEW-GUIDE.md) — View 작성 규칙 (라우팅, 생명주기, 금지 패턴)
- [VIEWMODEL-GUIDE](docs/VIEWMODEL-GUIDE.md) — ViewModel 작성 규칙 (LoadState, Output, CancelBag)
- [ADD-ENDPOINT-GUIDE](docs/ADD-ENDPOINT-GUIDE.md) — API 연동 순서 (DTO → Local → Endpoint → Repository → Interactor)
- [UI-GUIDE](docs/UI-GUIDE.md) — 디자인 시스템 사용 규칙

---

## 프로젝트 구조

```
saerok/Sources/
├── App/
│   ├── Dependency/            # DIContainer, AppEnvironment
│   ├── AppCoordinator.swift   # NavigationPath 라우팅 + 탭 루트 ViewModel 캐싱
│   ├── ViewModelFactory.swift # ViewModel 생성 전담
│   ├── AppStore.swift         # 전역 상태 (AppAction / AppEvent 2채널)
│   ├── AppState.swift
│   └── PushNotificationManager.swift  # FCM 토큰·딥링크 처리
│
├── Common/
│   ├── SRDesignSystem/        # 디자인 토큰·공통 컴포넌트·스타일
│   ├── StateManagement/       # Loadable(LoadState), Store, CancelBag
│   ├── Analytics/             # Amplitude 이벤트 추적
│   └── Utils/                 # Extensions, ImageLoader, Keychain 등
│
├── Feature/                   # 화면별 View/ + ViewModel/ 구조
│   ├── Collection/            # 개인 관찰 기록
│   ├── Community/             # 자유게시판·검색
│   ├── FieldGuide/            # 새 도감
│   ├── Login/                 # 소셜 로그인
│   ├── Map/                   # 지도 탐색
│   ├── MyPage/                # 마이페이지·알림·공지
│   ├── Onboarding/
│   └── Root/
│
├── Interactors/               # 비즈니스 로직 레이어 (프로토콜 + 구현체)
│
├── Repositories/              # 데이터 접근 레이어
│   ├── Models/                # DTO ↔ Local 모델 변환
│   └── ModelContainer.swift   # SwiftData 컨테이너
│
└── Network/
    ├── EndPoint/              # SREndpoint + 도메인별 extension (Auth, Birds, Community …)
    ├── API/                   # APIClient, APIService
    └── SRNetworkService.swift
```

각 Feature는 `View/` + `ViewModel/` 구조를 따르며, ViewModel은 `extension FeatureView { @Observable final class ViewModel }` 형태로 정의합니다.

---

## 테스트

**Swift Testing** (`@Suite` / `@Test` 매크로) 기반. Interactor 테스트는 Stub Repository를 주입해 작성합니다.

```bash
xcodebuild test -scheme saerok -destination 'platform=iOS Simulator,name=iPhone 16'
```

```
saerokTests/
├── CollectionInteractorTests.swift
├── CommunityInteractorTests.swift
├── FieldGuideInteractorTests.swift
├── MapInteractorTests.swift
├── UserInteractorTests.swift
└── LoadStateTests.swift
```

---

## 개발 환경

- Xcode 16+
- iOS 17.6+
- Swift 5.9+
- dev / production 빌드 환경 분리 (Firebase 설정 분기)

---

## License

This project is developed for the **apu** team.
