# ViewModel 작성 규칙

## 기본 구조

ViewModel은 반드시 **View의 extension 안에 중첩 클래스**로 선언한다.

```swift
extension CollectionView {
    @Observable
    final class ViewModel {
        // 1. 외부에서 읽기만 허용하는 상태
        private(set) var loadingState: LoadState<[Local.Collection]> = .notRequested
        private(set) var output: Output?

        // 2. 내부 의존성 (Combine 구독 등 @Observable 추적 불필요한 것)
        @ObservationIgnored private let cancelBag: CancelBag

        // 3. 주입받는 의존성
        private let appStore: AppStore
        private let collectionInteractor: CollectionInteractor

        init(appStore: AppStore, collectionInteractor: CollectionInteractor) {
            self.appStore = appStore
            self.collectionInteractor = collectionInteractor
            self.cancelBag = .init()
            bindAppStore()
        }
    }
}
```

**규칙:**
- `@Observable` + `final class` 조합 고정
- 상태 프로퍼티는 `private(set)` — View에서 읽기만 허용
- `CancelBag` 등 Combine 관련 객체는 `@ObservationIgnored` 필수
- `init`에서 `bindAppState()` 호출로 구독 설정

---

## LoadState 패턴

비동기 데이터 로딩은 반드시 `LoadState<T>`를 사용한다.

```swift
// 최초 로딩 (로딩 인디케이터 표시)
func loadPosts() async {
    guard loadingState == .notRequested || loadingState.inError else { return }
    loadingState = await loadingState.load {
        try await collectionInteractor.fetchMyCollections()
    }
}

// 새로고침 (로딩 인디케이터 없이 갱신)
func refresh() async {
    guard let current = loadingState.value else { return }
    do {
        let updated = try await collectionInteractor.fetchMyCollections()
        loadingState = .success(updated)
    } catch { }
}
```

---

## Output 열거형 (ViewModel → View 이벤트)

View로 보내는 이벤트는 `Output` enum을 통해서만 전달한다. 직접 coordinator를 ViewModel이 들고 있지 않는다.

```swift
enum Output: Equatable {
    case navigateToDetail(id: Int)
    case scrollToTop(UUID)
}

// ViewModel 내부
private(set) var output: Output?

func resetOutput() {
    output = nil
}
```

---

## AppStore 구독 — 두 채널 (Combine + CancelBag)

`AppStore`는 두 채널을 제공한다.

| 채널 | API | 용도 |
|------|-----|------|
| 상태 | `appStore.updates(for: keyPath)` | 영속 값 변화 감지 (authStatus, currentUser 등) |
| 이벤트 | `appStore.events` | 일회성 명령 (스크롤, 탭 간 화면 열기 등) |

`init`에서 `cancelBag.collect {}` 블록으로 한꺼번에 구독한다.

```swift
private func bindAppStore() {
    cancelBag.collect {
        // 일회성 이벤트 — compactMap으로 원하는 케이스만 추출
        appStore.events
            .compactMap { guard case .collectionDetailRequested(let id) = $0 else { return nil }; return id }
            .weakSink(on: self) { viewModel, id in
                viewModel.output = .navigateToDetail(id: id)
            }

        appStore.events
            .filter { if case .collectionScrollToTop = $0 { return true }; return false }
            .weakSink(on: self) { viewModel, _ in
                viewModel.output = .scrollToTop(UUID())
            }

        // 영속 상태 변화 감지
        appStore
            .updates(for: \.authStatus)
            .map { $0 == .guest }
            .removeDuplicates()
            .weakSink(on: self) { viewModel, isGuest in
                viewModel.isGuestMode = isGuest
            }
    }
}
```

**규칙:**
- `weakSink(on: self)` 사용 — retain cycle 방지
- 구독은 `cancelBag.collect {}` 블록 하나로 모은다
- AppState 변경: 반드시 `appStore.send(.action)` — 직접 keyPath 쓰기 금지
- 상태 단순 읽기(초기값 세팅): `appStore[\.authStatus]` subscript 허용

---

## 비동기 작업 패턴

### 병렬 로딩 — `withTaskGroup`
상세 화면처럼 여러 데이터를 동시에 로드할 때 사용한다.

```swift
func loadInitial() async {
    loadState = .loading
    await withTaskGroup(of: Void.self) { group in
        group.addTask { await self.fetchDetail() }
        group.addTask { await self.fetchComments() }
        group.addTask { await self.fetchSuggestions() }
        await group.waitForAll()
    }
    loadState = .success(())
}
```

### 검색 디바운스 — `Task.debounce`
텍스트 입력 후 지연 실행이 필요한 경우에 사용한다.

```swift
private var searchDebounceTask: Task<Void, Never>?

func updateSearchText(_ text: String) {
    searchDebounceTask = Task.debounce(delay: 400_000_000, task: searchDebounceTask) {
        await self.performSearch(text)
    }
}
```

---

## 게스트 모드 처리

```swift
// init에서 초기값 세팅 (subscript 읽기)
self.isGuestMode = appStore[\.authStatus] == .guest

// init에서 변화 감지 (cancelBag.collect 블록 내)
appStore.updates(for: \.authStatus)
    .map { $0 == .guest }
    .removeDuplicates()
    .weakSink(on: self) { viewModel, isGuest in viewModel.isGuestMode = isGuest }

func loadPosts() async {
    guard !isGuestMode else { return }
    // ...
}
```

---

## 금지 사항
- ViewModel이 `AppCoordinator`를 직접 참조하거나 주입받지 않는다 → Output으로 View에 위임
- `@MainActor` 전체 클래스 지정 금지 — 필요한 메서드에만 개별 지정
- UI 관련 import (`SwiftUI`) 최소화 — 불가피한 경우(`Color`, `Image` 타입)만 허용
- 비즈니스 로직을 ViewModel에 직접 작성 금지 → Interactor에 위임
