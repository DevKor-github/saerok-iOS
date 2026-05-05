# View 작성 규칙

## 기본 구조

```swift
struct CollectionView: View {
    typealias Route = CollectionRoute  // 라우트 타입 별칭

    // 1. 환경 의존성
    @Environment(\.injected) private var container
    @EnvironmentObject private var coordinator: AppCoordinator

    // 2. ViewModel (Bindable — @Observable 양방향 바인딩)
    @Bindable private var viewModel: ViewModel

    // 3. 로컬 UI 상태만 @State 허용
    @State private var scrollToTopTrigger = false

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            content
        }
        .task { await viewModel.loadPosts() }
        .navigationDestination(for: Route.self) { route in
            routeView(for: route)
        }
        .onChange(of: viewModel.output, initial: true) { _, output in
            handleOutput(output)
        }
    }
}
```

---

## 라우팅

화면 전환은 반드시 `coordinator.push()` / `coordinator.pop()`을 사용한다. View에서 다음 화면을 직접 생성하지 않는다.

```swift
// Route enum 정의 (파일 상단 또는 별도 파일)
enum CollectionRoute: AppRoute {
    case collectionDetail(Int)
    case addCollection(bird: Local.Bird?)
    case notification
}

// navigationDestination에서 라우트별 뷰 분기
@ViewBuilder
private func routeView(for route: Route) -> some View {
    switch route {
    case .collectionDetail(let id):
        CollectionDetailView(viewModel: coordinator.makeCollectionDetailViewModel(id: id))
    case .addCollection(let bird):
        AddCollectionView(viewModel: coordinator.makeAddCollectionViewModel(bird: bird))
    case .notification:
        NotificationView(viewModel: coordinator.makeNotificationViewModel())
    }
}

// 이동
coordinator.push(Route.collectionDetail(id))

// 뒤로가기
coordinator.pop()
```

---

## Output 처리 (ViewModel → View 이벤트)

```swift
private func handleOutput(_ output: ViewModel.Output?) {
    guard let output else { return }
    switch output {
    case .navigateToDetail(let id):
        coordinator.push(Route.collectionDetail(id))
    case .scrollToTop:
        scrollToTopTrigger.toggle()
    }
    viewModel.resetOutput()
}
```

`.onChange(of: viewModel.output, initial: true)`로 등록하고, 처리 후 반드시 `resetOutput()` 호출.

---

## 생명주기

| 상황 | 사용 |
|------|------|
| 최초 데이터 로드 | `.task { await viewModel.load() }` |
| 재진입 시 갱신 | `.onAppear { Task { await viewModel.refresh() } }` |
| 화면 이탈 처리 | `.onDisappear { ... }` |
| 앱 포그라운드 복귀 | `.onChange(of: scenePhase) { _, phase in if phase == .active { ... } }` |

`.task`는 뷰 생애주기에 맞춰 자동 취소되므로 최초 로딩에 우선 사용한다.

---

## NavigationBar

커스텀 `NavigationBar` 컴포넌트를 사용한다. SwiftUI 기본 `.navigationTitle`을 사용하지 않는다.

```swift
private var navigationBar: some View {
    NavigationBar(
        leading: {
            Button { coordinator.pop() } label: {
                Image.SRIconSet.chevronLeft
                    .frame(.defaultIconSize)
            }
            .srStyled(.borderedIconButton)
        },
        center: {
            Text("제목")
                .font(.SRFontSet.subtitle2)
        },
        trailing: {
            Button { coordinator.push(Route.notification) } label: {
                Image.SRIconSet.bell
                    .frame(.defaultIconSizeLarge)
            }
            .srStyled(.iconButton)
        }
    )
}
```

---

## LoadState 분기 렌더링

```swift
@ViewBuilder
private var content: some View {
    switch viewModel.loadingState {
    case .notRequested:
        EmptyView()
    case .loading:
        ProgressView()
    case .success(let items):
        loadedView(items)
    case .failure:
        errorView()
    }
}
```

---

## 공통 컴포넌트 사용 규칙

### 버튼
```swift
Button("확인") { }
    .buttonStyle(PrimaryButtonStyle())      // 주 CTA

Button("취소") { }
    .buttonStyle(SecondaryButtonStyle())    // 보조

Button("필터") { }
    .buttonStyle(FilterButtonStyle(isSelected: isActive))

Button { } label: { Image.SRIconSet.xmark }
    .srStyled(.iconButton)                 // 아이콘 버튼
    .srStyled(.borderedIconButton)         // 테두리 있는 아이콘 버튼
```

### 텍스트 필드
```swift
TextField("플레이스홀더", text: $text)
    .textFieldStyle(SRTextFieldStyle())
```

### 바텀시트 / 팝업 / 토스트
```swift
.srBottomSheet(isPresented: $showSheet) { SheetContentView() }
.srPopup(isPresented: $showPopup) { popupView }
.srToast(data: $toastData)
```

---

## 색상·폰트 사용

```swift
// 색상: Asset 이름으로 참조 (hex 하드코딩 금지)
.foregroundColor(.main)          // CTA, 활성 상태
.foregroundColor(.srGray)        // 보조 텍스트
.background(Color.srLightGray)   // 보조 배경

// 폰트: SRFontSet 사용 (시스템 폰트 직접 사용 금지)
.font(.SRFontSet.body1)
.font(.SRFontSet.headline1)
.font(.SRFontSet.caption1)
```

---

## 뷰 분리 기준

- `body`가 50줄을 넘으면 `private var` 또는 `private func`로 서브뷰 분리
- 반복 렌더링 되는 아이템(리스트 셀 등)은 별도 `struct`로 분리
- 공통으로 재사용 가능한 컴포넌트는 `saerok/Sources/Common/Views/`에 작성

```swift
// 서브뷰 분리 예시
var body: some View {
    VStack {
        navigationBar
        headerSection
        contentList
    }
}

private var headerSection: some View { ... }
private var contentList: some View { ... }
```

---

## Preview

```swift
#Preview {
    CollectionView(
        viewModel: .init(
            appState: .init(AppState()),
            collectionInteractor: DIContainer.Interactors.stub.collection
        )
    )
    .inject(.preview)   // stub DI 주입
}
```

---

## 금지 사항
- View가 Interactor / Repository를 직접 참조 — ViewModel을 통해서만 접근
- `NavigationLink(destination:)` 직접 사용 — `coordinator.push()` 사용
- `@StateObject` / `ObservableObject` 사용 — `@Bindable` + `@Observable` 사용
- `.navigationTitle()` / `.toolbar()` 사용 — 커스텀 `NavigationBar` 사용
- `Color(hex:)` 하드코딩 — Asset Catalog 컬러 이름 사용
- 시스템 폰트 직접 지정 — `SRFontSet` 사용
