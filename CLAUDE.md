# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# 프로젝트: 새록 (Saerok)

탐조(새 관찰) 기록·도감·커뮤니티·지도를 통합한 iOS 앱.

## 빌드 및 테스트

빌드·실행은 Xcode로 직접 수행. Makefile/Fastlane 없음.

```bash
# 테스트 실행 (시뮬레이터)
xcodebuild test -scheme saerok -destination 'platform=iOS Simulator,name=iPhone 16'
```

테스트 프레임워크는 **Swift Testing** (`@Suite`, `@Test` 매크로). XCTest 사용하지 않음.

## 기술 스택
- **UI**: SwiftUI + `@Observable` (iOS 17+)
- **아키텍처**: MVVM + Clean Architecture (5계층)
- **로컬 저장소**: SwiftData
- **네트워킹**: URLSession 기반 `SRNetworkService` 프로토콜 추상화 (Alamofire 미사용)
- **전역 상태**: Combine 기반 `Store<AppState>` (`CurrentValueSubject<AppState, Never>` 래퍼)
- **의존성 주입**: `DIContainer` + `@Environment`
- **주요 SDK**: Kakao(소셜 로그인), Firebase(푸시·원격설정), Naver Maps, Lottie, Amplitude

## 디렉토리 지도

| 작업 목적 | 찾아갈 경로 |
|----------|------------|
| 앱 진입·전역 상태 | `saerok/Sources/App/` |
| 새 화면 추가 | `saerok/Sources/Feature/{기능}/View/` + `ViewModel/` — **반드시 [VIEW-GUIDE](docs/VIEW-GUIDE.md)·[VIEWMODEL-GUIDE](docs/VIEWMODEL-GUIDE.md) 참고** |
| 비즈니스 로직 수정 | `saerok/Sources/Interactors/` |
| 데이터 모델·API 응답 변환 | `saerok/Sources/Repositories/Models/` |
| API 엔드포인트 추가 | `saerok/Sources/Network/EndPoint/` — **반드시 [ADD-ENDPOINT-GUIDE](docs/ADD-ENDPOINT-GUIDE.md) 참고** |
| 공통 컴포넌트·디자인 토큰 | `saerok/Sources/Common/SRDesignSystem/` |
| 공통 뷰 재사용 | `saerok/Sources/Common/Views/` |
| 유틸·익스텐션 | `saerok/Sources/Common/Utils/` |
| 화면 전환 | `saerok/Sources/App/AppCoordinator.swift` |
| 의존성 부트스트랩 | `saerok/Sources/App/Dependency/` |

## 개발 가이드 문서
- [VIEW-GUIDE](docs/VIEW-GUIDE.md) — View 작성 규칙 (라우팅, 생명주기, 컴포넌트 사용, 금지 패턴)
- [VIEWMODEL-GUIDE](docs/VIEWMODEL-GUIDE.md) — ViewModel 작성 규칙 (LoadState, Output, CancelBag, 비동기 패턴)
- [ADD-ENDPOINT-GUIDE](docs/ADD-ENDPOINT-GUIDE.md) — API 연동 순서 (DTO → Local → Endpoint → Repository → Interactor)

## 아키텍처 규칙
- CRITICAL: 레이어 흐름은 **View → ViewModel → Interactor → Repository → Network/SwiftData** 방향만 허용. 역방향 참조 금지.
- CRITICAL: 비즈니스 로직은 반드시 **Interactor**에 작성. ViewModel은 상태 관리·UI 이벤트만 처리.
- CRITICAL: 화면 전환은 반드시 **AppCoordinator**를 통해서만. View에서 직접 NavigationLink로 다음 화면을 참조하지 않는다.
- 새 기능 추가 시 파일 생성 순서: Model → Repository → Interactor(프로토콜+구현체) → ViewModel → View
- Interactor는 프로토콜 기반으로 작성해 Mock 구현체와 분리 (프리뷰·테스트용)
- 전역 상태 변경은 `appState.bulkUpdate()`로 묶어 불필요한 렌더링 방지

## ViewModel 구조 패턴

ViewModel은 **View의 중첩 extension 안에 `@Observable final class`** 로 선언한다. `@StateObject` / `ObservableObject` 사용 금지.

```swift
// SomeView.swift
struct SomeView: View {
    @Environment(\.injected) private var container: DIContainer
    @EnvironmentObject private var coordinator: AppCoordinator
    @Bindable private var viewModel: ViewModel  // @Bindable, NOT @StateObject

    var body: some View {
        content
            .task { await viewModel.loadData() }
            .onChange(of: viewModel.output, initial: true) { _, output in
                handleOutput(output)
            }
    }

    private func handleOutput(_ output: ViewModel.Output?) {
        guard let output else { return }
        switch output {
        case .navigateToDetail(let id):
            coordinator.push(Route.detail(id))
        }
        viewModel.resetOutput()
    }
}

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
            // AppState 구독은 cancelBag.collect {} 안에서 weakSink 사용
            cancelBag.collect {
                appState.updates(for: \.routing.someView.itemID)
                    .compactMap { $0 }
                    .weakSink(on: self) { vm, id in vm.output = .navigateToDetail(id: id) }
            }
        }

        func loadData() async {
            guard items == .notRequested || items.inError else { return }
            items = await items.load { try await someInteractor.fetchItems() }
        }

        func resetOutput() { output = nil }
    }
}
```

**ViewModel 인스턴스는 View에서 직접 생성하지 않는다.** `AppCoordinator`가 ViewModel factory 역할을 하며 lazy 프로퍼티로 캐싱한다.

```swift
// AppCoordinator.swift
@MainActor final class AppCoordinator: ObservableObject {
    lazy var someViewModel: SomeView.ViewModel = {
        SomeView.ViewModel(
            appState: container.appState,
            someInteractor: container.interactors.some
        )
    }()
}
```

## 상태 관리 패턴

```swift
// 비동기 상태: LoadState<T> 사용
@Observable class SomeViewModel {
    var items: LoadState<[Item]> = .notRequested
}

// LoadState.load {} — .loading 세팅 후 작업 실행, 결과로 .success/.failure 반환
items = await items.load { try await interactor.fetchItems() }

// 전역 상태 읽기/쓰기
container.appState[\.currentUser]
container.appState.bulkUpdate { $0.routing.someView.itemID = id }
```

## API 엔드포인트 추가

`SREndpoint` enum에 케이스를 추가할 때 반드시 6개 항목을 모두 처리해야 한다.

```swift
enum SREndpoint: Endpoint {
    case somethingList(page: Int, size: Int)

    var path: String {
        switch self {
        case .somethingList: return "something/list"
        }
    }

    var method: HTTPMethod { .get }

    var requiresAuth: Bool { true }   // 인증 불필요 시 TokenManager.shared.getAccessToken() != nil

    var queryItems: [String: String]? {
        switch self {
        case .somethingList(let page, let size):
            return ["page": "\(page)", "size": "\(size)"]
        }
    }

    var expectedResponseType: Decodable.Type {
        switch self {
        case .somethingList: return DTO.SomethingListResponse.self
        }
    }
}
```

## UI 규칙
- CRITICAL: 색상은 반드시 **Asset Catalog 이름**으로 참조 (`Color.main`, `.srWhite`, `.srGray` 등). hex 하드코딩 금지.
- CRITICAL: 폰트는 반드시 **`SRFontSet`** 을 통해 적용 (`.font(.SRFontSet.body1)`). 시스템 폰트 직접 사용 금지.
- 레이아웃 상수는 가능하면 `SRDesignConstant` 사용 (cornerRadius: 24, cardCornerRadius: 10, defaultPadding: 24)
- 버튼 스타일: `PrimaryButtonStyle` / `SecondaryButtonStyle` / `FilterButtonStyle` / `SRIconButtonStyle` 재사용
- 바텀시트·팝업·토스트는 `.srBottomSheet()` / `.srPopup()` / `.srToast()` modifier 사용
- `.navigationTitle()` 사용 금지 — 공통 `NavigationBar` 컴포넌트 사용

**UI 안티패턴 (절대 금지)**
- `blur` / `ultraThinMaterial` 남용
- 그라데이션 텍스트, 네온·글로우 shadow
- 보라/인디고 계열 임의 색상 추가
- 배경 장식 도형·그라데이션 orb
- 화면 전체 shake·반복 pulse 애니메이션
- `.main` 컬러를 CTA·활성 상태 외에 남용

## 이미지 업로드 흐름
S3 Presigned URL 방식: 백엔드에서 URL 발급 → S3 직접 업로드 → 백엔드에 메타데이터 등록 → 실패 시 채집 기록 전체 롤백

## 테스트 패턴

```swift
@Suite("SomeInteractor")
struct SomeInteractorTests {
    @Test("fetchItems: 최신순 정렬")
    func fetchItemsSortedByDate() async throws {
        let interactor = SomeInteractorImpl(repository: StubSomeRepository())
        let items = try await interactor.fetchItems()
        #expect(items.map(\.createdAt) == items.map(\.createdAt).sorted(by: >))
    }

    private struct StubSomeRepository: SomeRepository {
        func fetchItems() async throws -> [Local.Item] { [/* stub data */] }
    }
}
```

Interactor 테스트는 실제 Repository 대신 **Stub struct**를 직접 구현해 주입한다.

## 커밋 메시지
`feat:` / `fix:` / `refactor:` / `docs:` / `chore:` conventional commits 형식 사용
