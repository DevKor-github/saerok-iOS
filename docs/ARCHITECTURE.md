# 새록 아키텍처 가이드

> 작성일: 2026-05-08  
> 대상: 새 기여자, 포트폴리오 리뷰어, 미래의 나

---

## 1. 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                      Feature Layer                          │
│  View ◄─── @Bindable ViewModel (View extension 안에 선언)     │
│               │  Output enum  │  LoadState<T>               │
└───────────────│───────────────│─────────────────────────────┘
                │ async/await
┌───────────────▼─────────────────────────────────────────────┐
│                    Interactor Layer                         │
│  protocol XxxInteractor  ←─→  XxxInteractorImpl             │
│  (비즈니스 로직: 정렬·필터·검증·합성)                               │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    Repository Layer                         │
│  protocol XxxRepository ◄─── MainRepository (단일 구현체)      │
│  DTO → Local 모델 변환 담당                                    │
└──────────┬────────────────────────────────────────┐         │
           │                                        │         │
┌──────────▼──────────┐             ┌───────────────▼──────┐  │
│   Network Layer     │             │   SwiftData Layer    │  │
│  SRNetworkService   │             │  ModelContainer      │  │
│  APIClient(URLSess) │             │  (로컬 캐시)           │  │
│  SREndpoint enum    │             └──────────────────────┘  │
└─────────────────────┘
```

**단방향 흐름 강제**: View → ViewModel → Interactor → Repository → Network/SwiftData  
역방향 참조 금지. 컴파일러로 강제되지 않으므로 PR 리뷰와 이 문서로 통제.

---

## 2. 레이어별 파일 분포

| 레이어 | 경로 | 파일 수 | 역할 |
|--------|------|---------|------|
| App | `Sources/App/` | 8 | 진입점, 전역 상태, DI 부트스트랩 |
| Feature | `Sources/Feature/` | 91 | View + ViewModel (8개 Feature) |
| Common | `Sources/Common/` | 77 | 디자인 시스템, 유틸, 공통 뷰 |
| Interactor | `Sources/Interactors/` | 6 | 비즈니스 로직 |
| Repository | `Sources/Repositories/` | 71 | 데이터 접근 + DTO↔Local 변환 |
| Network | `Sources/Network/` | 7 | HTTP 추상화, 엔드포인트 정의 |
| **합계** | | **260** | |

### 디렉토리 지도

```
saerok/Sources/
├── App/
│   ├── AppState.swift              # 전역 상태 구조체
│   ├── AppCoordinator.swift        # 네비게이션 + ViewModel 캐시
│   ├── ViewModelFactory.swift      # ViewModel 생성 팩토리
│   └── Dependency/
│       ├── DIContainer.swift       # DI 컨테이너 구조체
│       └── AppEnvironment.swift    # 부트스트랩 로직
│
├── Common/
│   ├── SRDesignSystem/             # 색상, 폰트, 공통 컴포넌트 (45+ 파일)
│   ├── Utils/                      # Extensions, Helper, ImageLoader 등 (32 파일)
│   ├── Loadable.swift              # LoadState<T> enum
│   ├── CancelBag.swift             # Combine 구독 관리 (@resultBuilder)
│   └── Store.swift                 # CurrentValueSubject<State> 래퍼
│
├── Feature/
│   ├── Collection/  (35 파일)      # 채집 기록 CRUD + 댓글/좋아요
│   ├── Community/   (18 파일)      # 자유게시판 + 검색
│   ├── FieldGuide/  ( 7 파일)      # 조류 도감
│   ├── Map/         (10 파일)      # 지도 + 클러스터링
│   ├── MyPage/      ( 8 파일)      # 프로필 + 설정
│   ├── Login/       ( 8 파일)      # 카카오·애플 로그인
│   ├── Onboarding/  ( 3 파일)      # 앱 소개 흐름
│   └── Root/        ( 2 파일)      # 탭바 컨테이너
│
├── Interactors/                    # 프로토콜 + Impl (5쌍 + 이미지업로드)
├── Network/
│   ├── API/                        # APIClient (URLSession + Codable)
│   └── EndPoint/                   # SREndpoint, KakaoEndpoint enum
└── Repositories/
    └── Models/
        ├── Local/                  # 도메인 모델 (Swift struct)
        └── DTO/                    # API 응답 Codable struct
```

---

## 3. 디자인 패턴 요약

| 패턴 | 사용처 |
|------|--------|
| Repository Pattern | 데이터 소스 추상화, DTO→Local 변환 |
| Interactor / Use Case | 비즈니스 로직 캡슐화 |
| Coordinator Pattern | 화면 전환 (`AppCoordinator`) |
| Dependency Injection | `DIContainer` + `@Environment` |
| Observer Pattern | Combine (`Store<AppState>`), `@Observable` |
| Builder Pattern | `@resultBuilder` 기반 `CancelBag` |
| Factory Pattern | `ViewModelFactory` — ViewModel 생성 일원화 |

---

## 4. 의존성 주입 (DI)

### DIContainer 구조

```swift
struct DIContainer {
    let appState: Store<AppState>
    let interactors: Interactors
    let networkService: SRNetworkService

    struct Interactors {
        let fieldGuide: FieldGuideInteractor
        let collection: CollectionInteractor
        let community: CommunityInteractor
        let map: MapInteractor
        let user: UserInteractor

        static let stub: Interactors = .init(/* Mock 구현체 */)
    }
}
```

### 부트스트랩 순서 (`AppEnvironment.bootstrap()`)

```
1. SwiftData ModelContainer 초기화
2. Store<AppState> 생성
3. SRNetworkServiceImpl 생성 (URLSession 래퍼)
4. MainRepository 생성 (5개 Repository 프로토콜 단일 구현체)
5. Interactor 5개 생성 (Repository 주입)
6. DIContainer 조립
7. SwiftUI 루트에 .inject(diContainer) 주입
```

### 주입·소비 방식

```swift
// 루트: 한 번만 inject
ContentView().inject(diContainer)

// 하위 View: 꺼내 쓰기
@Environment(\.injected) private var container: DIContainer

// ViewModel 생성은 View가 직접 하지 않음 — AppCoordinator가 lazy 캐싱
@EnvironmentObject private var coordinator: AppCoordinator
// coordinator.collectionViewModel, coordinator.mapViewModel …
```

테스트·프리뷰에서는 `DIContainer.Interactors.stub`의 Mock 구현체 자동 사용.

---

## 5. 상태 관리

### 두 가지 상태 채널

| 채널 | 타입 | 변경 빈도 | 용도 |
|------|------|----------|------|
| `Store<AppState>` | `CurrentValueSubject` 래퍼 | 낮음 | 전역 공유 상태 (인증, 라우팅) |
| `LoadState<T>` | enum (ViewModel 프로퍼티) | 높음 | 비동기 데이터 상태 |

### AppState 구조

```swift
struct AppState: Equatable {
    var routing = ViewRouting()     // 탭·뷰 라우팅 (UI 전용)
    var authStatus: AuthStatus      // 인증 상태 (도메인)
    var currentUser: UserProfile?   // 로그인 사용자 (도메인)
}
```

> **설계 한계**: UI 상태(routing, 변경 빈도 높음)와 도메인 상태(authStatus·currentUser, 변경 빈도 낮음)가 동일 Equatable 구조체에 공존. 탭 전환마다 도메인 상태 비교도 트리거됨. 현재 규모에서는 허용 가능.

### 비동기 상태 패턴

```swift
var items: LoadState<[Local.Item]> = .notRequested

func loadData() async {
    guard items == .notRequested || items.inError else { return }
    items = await items.load { try await interactor.fetchItems() }
}
// LoadState.load {} → .loading 설정 → 작업 실행 → .success / .failed 반환
```

### 전역 상태 읽기·쓰기

```swift
// 읽기
let user = container.appState[\.currentUser]

// 쓰기 (배치 업데이트로 불필요한 렌더링 방지)
container.appState.bulkUpdate { $0.routing.collectionView.selectedId = id }
```

---

## 6. 네비게이션 (AppCoordinator)

```swift
@MainActor final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()  // 앱 전체 단일 NavigationStack
    let factory: ViewModelFactory

    // 탭 루트 ViewModel — 로그아웃 시 nil, 재진입 시 lazy 재생성
    private var _collectionViewModel: CollectionView.ViewModel?
    var collectionViewModel: CollectionView.ViewModel {
        if _collectionViewModel == nil { _collectionViewModel = factory.makeCollectionViewModel() }
        guard let vm = _collectionViewModel else { fatalError("ViewModel 생성 실패") }
        return vm
    }
    // … collection, community, map, myPage, fieldGuide
}
```

- `coordinator.push(Route.detail(id))` → path에 Route append
- `coordinator.pop()` / `coordinator.clear()`
- 로그아웃 시 `reset()` → 모든 `_xxxViewModel = nil`

**특이사항**: 탭마다 별도 NavigationStack이 없고 단일 path 사용. 탭 전환 시 뒤로가기 스택이 공유됨.

---

## 7. ViewModel 패턴

```swift
// SomeView.swift 내부 — View의 extension으로 네임스페이스 격리
extension SomeView {
    @Observable final class ViewModel {
        enum Output: Equatable {
            case navigateToDetail(id: Int)
        }

        private(set) var items: LoadState<[Local.Item]> = .notRequested
        private(set) var output: Output?

        @ObservationIgnored private let cancelBag = CancelBag()
        private let appState: Store<AppState>
        private let someInteractor: SomeInteractor

        init(appState: Store<AppState>, someInteractor: SomeInteractor) {
            self.appState = appState
            self.someInteractor = someInteractor
            cancelBag.collect {
                appState.updates(for: \.routing.someView.itemID)
                    .compactMap { $0 }
                    .weakSink(on: self) { vm, id in vm.output = .navigateToDetail(id: id) }
            }
        }

        func resetOutput() { output = nil }
    }
}
```

**규칙**:
- `@StateObject` / `ObservableObject` 금지 → `@Observable` + `@Bindable` 사용
- ViewModel은 View extension 안에서 선언해 이름 충돌 방지
- Output enum으로 네비게이션 이벤트를 단방향 전달 → `resetOutput()`으로 소비 후 초기화

---

## 8. 네트워크 레이어

```
SRNetworkService (protocol)
└── SRNetworkServiceImpl
        └── APIClient (URLSession + Codable)
                └── SREndpoint enum (type-safe URL 빌더)
```

### 엔드포인트 추가 체크리스트 (6개 항목 필수)

```swift
enum SREndpoint: Endpoint {
    case collectionList(page: Int, size: Int)

    var path: String { ... }                          // 1
    var method: HTTPMethod { ... }                    // 2
    var requiresAuth: Bool { ... }                    // 3
    var queryItems: [String: String]? { ... }         // 4
    var body: Encodable? { ... }                      // 5
    var expectedResponseType: Decodable.Type { ... }  // 6
}
```

switch exhaustiveness로 누락된 케이스를 컴파일러가 감지.  
자세한 내용은 [ADD-ENDPOINT-GUIDE.md](./ADD-ENDPOINT-GUIDE.md) 참고.

### 이미지 업로드 흐름 (S3 Presigned URL)

```
1. 백엔드 → Presigned URL 발급
2. S3 직접 PUT 업로드
3. 백엔드에 메타데이터 등록
4. 실패 시 deleteCollection() 호출 (부분 롤백)
   ⚠️ S3 오브젝트 자체는 미정리 — 알려진 한계
```

---

## 9. 외부 의존성

| 패키지 | 용도 |
|--------|------|
| lottie-ios | 애니메이션 |
| SPM-NMapsMap | 네이버 지도 SDK |
| kakao-ios-sdk | 카카오 소셜 로그인 |
| firebase-ios-sdk | 푸시 알림, 원격 설정 |
| adfit-spm | 인앱 광고 |
| AmplitudeUnified-Swift | 이벤트 분석 |

> `CLAUDE.md`에 Alamofire가 언급되어 있으나 실제 구현은 URLSession 기반 `APIClient`를 사용. Alamofire 미사용.

