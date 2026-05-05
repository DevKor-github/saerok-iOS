# 아키텍처

## 디렉토리 구조

```
saerok/Sources/
├── App/                        # 앱 진입점, 상태, 의존성 주입
│   ├── AppState.swift          # 전역 상태 구조체
│   ├── AppCoordinator.swift    # 네비게이션 코디네이터 + ViewModel 팩토리
│   └── Dependency/             # DIContainer, AppEnvironment 부트스트랩
├── Common/                     # 공통 유틸리티 + 디자인 시스템
│   ├── DesignSystem/           # 색상, 폰트, 컴포넌트
│   ├── Utils/                  # Extensions, Helper, Store, Loadable
│   └── Views/                  # 공통 SwiftUI 컴포넌트
├── Feature/                    # 기능별 모듈
│   ├── Collection/             # 채집 기록 기능
│   ├── Community/              # 커뮤니티 기능
│   ├── FieldGuide/             # 도감 기능
│   ├── Login/                  # 로그인/인증
│   ├── Map/                    # 지도 기능
│   ├── MyPage/                 # 마이페이지
│   ├── Onboarding/             # 온보딩
│   └── Root/                   # 루트 탭 뷰
├── Interactors/                # 비즈니스 로직 (Use Case)
├── Network/                    # HTTP 네트워킹 레이어
│   ├── API/                    # APIClient (URLSession 래퍼)
│   ├── EndPoint/               # SREndpoint, KakaoEndpoint
│   └── SRNetworkService.swift  # 네트워크 서비스 프로토콜
└── Repositories/               # 데이터 접근 추상화
    └── Models/                 # DTO ↔ Local 도메인 모델
```

각 Feature 내부 구조:
```
Feature/{FeatureName}/
├── View/                       # SwiftUI 뷰
└── ViewModel/                  # @Observable ViewModel
```

## 패턴

**MVVM + Clean Architecture (레이어드 아키텍처)**

- **View**: SwiftUI, `@Environment`로 주입된 ViewModel·DIContainer를 구독
- **ViewModel**: `@Observable` 매크로 사용, LoadState로 비동기 상태 관리
- **Interactor (Use Case)**: 비즈니스 로직 담당, 프로토콜 기반으로 Mock 구현체와 분리
- **Repository**: 네트워크·로컬 스토리지 추상화, DTO → Local 모델 변환 담당
- **Network**: 타입 안전한 Endpoint 프로토콜, Alamofire 기반 `DefaultAPIClient`

**디자인 패턴 요약**

| 패턴 | 사용처 |
|------|--------|
| Repository Pattern | 데이터 소스 추상화 |
| Interactor / Use Case | 비즈니스 로직 캡슐화 |
| Coordinator Pattern | 화면 전환 (`AppCoordinator`) |
| Dependency Injection | `DIContainer` + `@Environment` |
| Observer Pattern | Combine (`Store`), `@Observable` |
| Builder Pattern | `@resultBuilder` 기반 `CancelBag` |

## 데이터 흐름

```
사용자 입력
    ↓
SwiftUI View (@Environment 주입, @Observable 구독)
    ↓
ViewModel (LoadState 관리, async 메서드 호출)
    ↓
Interactor (비즈니스 로직, 유효성 검사, 정렬·필터)
    ↓
Repository (데이터 소스 조합: 네트워크 + 로컬)
    ↓
SRNetworkService / SwiftData
    ↓ ↑
외부 API 응답 (DTO) → Local 모델 변환
    ↑
응답 → ViewModel 상태 업데이트 → UI 자동 갱신
```

**이미지 업로드 특수 흐름:**
```
이미지 선택
    → 백엔드에서 S3 Presigned URL 발급
    → 이미지를 S3에 직접 업로드
    → 백엔드에 이미지 메타데이터 등록
    → 실패 시 채집 기록 롤백
```

**비동기 병렬 로딩:**
`withTaskGroup`으로 상세 데이터, 댓글, 연관 항목을 동시에 로드

## 상태 관리

### 전역 상태 — `AppState` + `Store<T>`

```swift
// Store = CurrentValueSubject<State, Never> (Combine)
let appState = Store<AppState>(AppState())
```

`AppState`에는 아래 하위 상태가 포함됨:
- `routing` — 화면별 네비게이션 경로
- `system` — 앱 버전, 네트워크 상태
- `authStatus` — 인증 여부
- `currentUser` — 로그인 유저 정보

`KeyPath` 서브스크립트로 타입 안전하게 접근하고, `bulkUpdate()`로 여러 상태를 배치 업데이트한다.

### 로컬 컴포넌트 상태 — `LoadState<T>` + `@Observable`

```swift
enum LoadState<T> {
    case notRequested
    case loading
    case success(T)
    case failure(Error)
}
```

ViewModel이 `@Observable`로 선언되어 SwiftUI가 자동으로 변경 감지.

### 구독 관리 — `CancelBag`

Combine 구독을 `@resultBuilder` 기반의 `CancelBag`으로 한 곳에서 관리해 메모리 누수를 방지한다.

## 의존성 주입

앱 시작 시 `AppEnvironment.bootstrap()`에서 모든 의존성을 구성한다:

```
AppEnvironment.bootstrap()
    → SRNetworkServiceImpl
    → SwiftData ModelContainer
    → Repositories (MainRepository 등)
    → Interactors (각 feature별)
    → DIContainer (AppState + Interactors + NetworkService)
```

뷰에 주입:
```swift
// 루트에서 한 번만 inject
ContentView().inject(diContainer)

// 하위 뷰에서 꺼내 쓰기
@Environment(\.injected) var container
```

테스트·프리뷰에서는 `DIContainer.Interactors.stub`의 Mock 구현체가 자동으로 사용된다.

## 주요 외부 의존성

| 라이브러리 | 용도 |
|-----------|------|
| Alamofire 5 | HTTP 네트워킹 |
| SwiftData | 로컬 영속성 (Apple 네이티브) |
| Kakao iOS SDK | 소셜 로그인 |
| Firebase 12 | 푸시 알림, 원격 설정 |
| Naver Maps SDK | 지도 |
| Lottie 4 | 애니메이션 |
| Amplitude | 사용자 이벤트 분석 |
| AdFit | 광고 |
