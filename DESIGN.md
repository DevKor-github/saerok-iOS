# DESIGN.md

**saerok-iOS Design System & UI Guidelines**

This document describes the design patterns, UI components, and styling conventions used in the saerok-iOS project.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Design Principles](#2-design-principles)
3. [Color System](#3-color-system)
4. [Typography](#4-typography)
5. [Component Library](#5-component-library)
6. [Layout Patterns](#6-layout-patterns)
7. [Navigation Patterns](#7-navigation-patterns)
8. [Animation & Transitions](#8-animation--transitions)
9. [Accessibility](#9-accessibility)
10. [Best Practices](#10-best-practices)

---

## 1. Overview

The saerok-iOS design system is located in `Sources/Common/SRDesignSystem/` and provides:

- Reusable UI components
- Consistent styling patterns
- Typography system
- Layout utilities
- Custom modifiers

All UI components follow a unified styling approach using the `SRComponentStyle` enum.

---

## 2. Design Principles

### 2.1 Core Principles

1. **Consistency** - Use existing components before creating new ones
2. **Simplicity** - Keep UI code clean and maintainable
3. **Reusability** - Build components that can be used across features
4. **Accessibility** - Ensure all components are accessible
5. **Performance** - Optimize for smooth animations and transitions

### 2.2 SwiftUI Conventions

- Use `@Observable` for reactive state
- Prefer composition over inheritance
- Use `@ViewBuilder` for conditional rendering
- Keep View files focused and modular
- Extract complex UI into Components

---

## 3. Color System

### 3.1 Color Palette

Colors are defined in `Assets.xcassets`.

**Primary Colors:**
- Primary: Main brand color
- Secondary: Accent color
- Background: Main background
- Surface: Card/container background

**Semantic Colors:**
- Success: Green for positive actions
- Warning: Yellow for warnings
- Error: Red for errors
- Info: Blue for information

**Text Colors:**
- Primary Text: Main text color
- Secondary Text: Subdued text
- Disabled Text: Inactive text
- Link: Interactive text

### 3.2 Using Colors

```swift
// From Assets
Color("Primary")
Color("Background")

// Semantic colors
.foregroundColor(.primary)
.foregroundColor(.secondary)

// Gradients
LinearGradient.srGradient // Custom gradient extension
```

---

## 4. Typography

### 4.1 Font System

Located in: `Sources/Common/SRDesignSystem/SRFontSet.swift`

**Available Fonts:**
- **Pretendard** - Main UI font (variable font)
- **Jalpullineunharu Medium** - Decorative font for special UI
- **Moneygraphy Rounded** - Numbers and special typography

### 4.2 Font Hierarchy

```swift
// Common font styles
.font(.system(size: 28, weight: .bold))      // Large Title
.font(.system(size: 22, weight: .semibold))  // Title
.font(.system(size: 17, weight: .medium))    // Headline
.font(.system(size: 15, weight: .regular))   // Body
.font(.system(size: 13, weight: .regular))   // Caption
```

### 4.3 Custom Fonts

```swift
// Using Pretendard
.font(.custom("PretendardVariable", size: 16))

// Using Jalpullineunharu
.font(.custom("JalpullineunharuMedium", size: 18))
```

---

## 5. Component Library

All components use the `SRComponentStyle` enum for consistent styling.

### 5.1 Styling Pattern

```swift
enum SRComponentStyle {
    case textField(isFocused: FocusState<Bool>.Binding, alwaysFocused: Bool = false, tintColor: Color? = nil)
    case filterButton(isActive: Bool, isResetButton: Bool = false)
    case primaryButton
    case secondaryButton
    case iconButton
    case avatar
    case defaultItem
}

extension View {
    func srStyled(_ style: SRComponentStyle) -> some View {
        style.apply(to: self)
    }
}
```

### 5.2 Buttons

#### Primary Button

**Usage:**
```swift
Button("Submit") {
    // Action
}
.srStyled(.primaryButton)
```

**Style:** PrimaryButtonStyle
- Solid background with primary color
- White text
- Rounded corners
- Full width or fixed size

#### Secondary Button

**Usage:**
```swift
Button("Cancel") {
    // Action
}
.srStyled(.secondaryButton)
```

**Style:** SecondaryButtonStyle
- Outlined style with transparent background
- Primary color border and text
- Rounded corners

#### Icon Button

**Usage:**
```swift
Button {
    // Action
} label: {
    Image(systemName: "heart")
}
.srStyled(.iconButton)
```

**Style:** SRIconButtonStyle
- Circular or square icon container
- Optional background
- Used for toolbar actions

#### Filter Button

**Usage:**
```swift
Button("Filter") {
    // Action
}
.srStyled(.filterButton(isActive: isSelected, isResetButton: false))
```

**Style:** FilterButtonStyle
- Pill-shaped button
- Changes appearance when active
- Used in filter bars

#### Filter Bar

**Usage:**
```swift
FilterBar(
    filters: ["All", "Birds", "Photos"],
    selectedFilter: $selectedFilter
)
```

**Component:** Custom component for horizontal filter selection

### 5.3 Text Fields

#### Standard Text Field

**Usage:**
```swift
@FocusState private var isFocused: Bool

TextField("Placeholder", text: $text)
    .srStyled(.textField(isFocused: $isFocused))
```

**Features:**
- Custom border styling
- Focus state handling
- Optional tint color
- Auto-focus support

#### Password Field

**Usage:**
```swift
PasswordField(text: $password, placeholder: "Password")
```

**Component:** Custom secure text field with show/hide toggle

#### Deletable Text Field

**Usage:**
```swift
TextField("Search", text: $query)
    .textFieldDeletable($query)
```

**Modifier:** Adds clear button to text field

### 5.4 Sheets & Modals

#### Custom Bottom Sheet

**Usage:**
```swift
.srBottomSheet(isPresented: $showSheet) {
    // Sheet content
}
```

**Features:**
- Custom presentation style
- Drag-to-dismiss
- Dynamic height
- Custom corner radius

#### Dynamic Sheet

**Usage:**
```swift
.sheet(isPresented: $showSheet) {
    DynamicSheet {
        // Content
    }
}
```

**Component:** Sheet with dynamic height based on content

#### Enum Selection Sheet

**Usage:**
```swift
.enumSelectionSheet(
    isPresented: $showPicker,
    selection: $selectedValue,
    options: MyEnum.allCases
)
```

**Component:** Generic picker sheet for enum types

### 5.5 Navigation Components

#### Navigation Bar

**Usage:**
```swift
NavigationBar(
    title: "Title",
    leftButton: { BackButton() },
    rightButton: { MenuButton() }
)
```

**Component:** Custom navigation bar with flexible buttons

#### Tab Bar

**Usage:**
```swift
TabbarView(
    selectedTab: $selectedTab,
    items: TabbedItems.allCases
)
```

**Component:** Custom tab bar with icon and label

### 5.6 Image Components

#### Avatar

**Usage:**
```swift
AsyncImage(url: imageURL) { image in
    image.resizable()
}
.srStyled(.avatar)
```

**Style:** Circular image with border

#### Image Picker

**Usage:**
```swift
ImagePicker(image: $selectedImage, isPresented: $showPicker)
```

**Component:** Single image picker

#### Multi Image Picker

**Usage:**
```swift
MultiImagePicker(images: $selectedImages, isPresented: $showPicker)
```

**Component:** Multiple image selection

#### Async Image with Metadata

**Usage:**
```swift
ReactiveAsyncImageWithMetadata(
    url: imageURL,
    placeholder: { ProgressView() }
)
```

**Component:** Image loader with size detection and metadata

### 5.7 Grid Layouts

#### Staggered Grid

**Usage:**
```swift
StaggeredGrid(columns: 2, spacing: 16) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

**Component:** Pinterest-style staggered grid layout

#### Adaptive Left-Aligned Grid

**Usage:**
```swift
AdaptiveLeftAlignedGrid(spacing: 8) {
    ForEach(tags) { tag in
        TagView(tag: tag)
    }
}
```

**Component:** Left-aligned flow layout for tags/chips

### 5.8 Loading & Empty States

#### Shimmer Effect

**Usage:**
```swift
RoundedRectangle(cornerRadius: 8)
    .fill(Color.gray.opacity(0.3))
    .shimmer()
```

**Modifier:** Animated shimmer loading effect

#### Loading View

**Pattern:**
```swift
@ViewBuilder
private var content: some View {
    switch viewModel.loadingState {
    case .notRequested:
        emptyView()
    case .loading:
        ProgressView()
    case .success(let data):
        loadedView(data)
    case .failure(let error):
        errorView(error)
    }
}
```

### 5.9 Popups & Alerts

#### SR Popup

**Usage:**
```swift
.srPopup(isPresented: $showPopup) {
    VStack {
        Text("Popup Content")
        Button("Close") { showPopup = false }
    }
}
```

**Component:** Custom popup overlay

#### SR Alert Style

**Usage:**
```swift
.alert("Title", isPresented: $showAlert) {
    Button("OK", role: .cancel) { }
}
.alertStyle(.srAlert)
```

**Style:** Custom alert styling

---

## 6. Layout Patterns

### 6.1 Screen Structure

Standard screen layout:

```swift
struct FeatureView: View {
    @Bindable private var viewModel: ViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            content
                .navigationBar(
                    title: "Title",
                    leftButton: backButton,
                    rightButton: menuButton
                )
        }
    }

    @ViewBuilder
    private var content: some View {
        // Main content
    }
}
```

### 6.2 Spacing Guidelines

**Standard Spacing:**
- Extra Small: 4pt
- Small: 8pt
- Medium: 16pt
- Large: 24pt
- Extra Large: 32pt

**Usage:**
```swift
VStack(spacing: 16) { }
.padding(.horizontal, 16)
.padding(.vertical, 24)
```

### 6.3 Corner Radius

**Standard Radii:**
- Small: 8pt (buttons, text fields)
- Medium: 12pt (cards, containers)
- Large: 16pt (sheets, large cards)
- Extra Large: 20pt (special containers)

**Custom Rounded Corners:**
```swift
.cornerRadius(12, corners: [.topLeft, .topRight])
```

### 6.4 Shadows & Elevation

```swift
// Light shadow
.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

// Medium shadow
.shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

// Heavy shadow
.shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
```

---

## 7. Navigation Patterns

### 7.1 Navigation Stack

**Pattern:**
```swift
NavigationStack(path: $coordinator.path) {
    MainView(viewModel: coordinator.mainViewModel)
}
.navigationDestination(for: Route.self) { route in
    switch route {
    case .detail(let id):
        DetailView(viewModel: coordinator.makeDetailViewModel(id: id))
    case .edit:
        EditView(viewModel: coordinator.makeEditViewModel())
    }
}
```

### 7.2 Tab Navigation

**Pattern:**
```swift
TabbarView(selectedTab: $selectedTab, items: TabbedItems.allCases)
    .overlay {
        switch selectedTab {
        case .map: MapView()
        case .collection: CollectionView()
        case .community: CommunityView()
        case .myPage: MyPageView()
        }
    }
```

### 7.3 Sheet Presentation

**Pattern:**
```swift
.sheet(isPresented: $showSheet) {
    SheetContent()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
```

### 7.4 Full Screen Cover

**Pattern:**
```swift
.fullScreenCover(isPresented: $showFullScreen) {
    FullScreenView()
}
```

---

## 8. Animation & Transitions

### 8.1 Standard Animations

**Default Animation:**
```swift
withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
    // State change
}
```

**Smooth Animation:**
```swift
withAnimation(.easeInOut(duration: 0.2)) {
    // State change
}
```

### 8.2 Transitions

**Slide Transition:**
```swift
.transition(.move(edge: .trailing))
```

**Opacity Transition:**
```swift
.transition(.opacity)
```

**Combined Transition:**
```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
))
```

### 8.3 Lottie Animations

**Usage:**
```swift
LottieView(filename: "splash", loopMode: .loop)
    .frame(width: 200, height: 200)
```

**Component:** Located in `Sources/Common/Utils/LottieView.swift`

---

## 9. Accessibility

### 9.1 Semantic Labels

**Always provide accessibility labels:**
```swift
Button {
    // Action
} label: {
    Image(systemName: "heart")
}
.accessibilityLabel("Like")
```

### 9.2 Dynamic Type

**Support dynamic type:**
```swift
Text("Title")
    .font(.headline)
    .minimumScaleFactor(0.8)
    .lineLimit(2)
```

### 9.3 VoiceOver

**Group related content:**
```swift
HStack {
    Image(systemName: "star")
    Text("4.5")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Rating: 4.5 stars")
```

### 9.4 Color Contrast

- Ensure text has sufficient contrast ratio (4.5:1 minimum)
- Provide alternative indicators beyond color
- Test with accessibility inspector

---

## 10. Best Practices

### 10.1 Component Reusability

**DO:**
- Use existing design system components
- Follow the `srStyled()` pattern
- Extract reusable UI into Components folder
- Keep components generic and configurable

**DON'T:**
- Create custom styling patterns
- Hardcode colors or fonts
- Duplicate component logic
- Mix styling approaches

### 10.2 View Organization

**Structure:**
```swift
struct FeatureView: View {
    // MARK: - Properties
    @Bindable private var viewModel: ViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var localState: Bool = false

    // MARK: - Body
    var body: some View {
        content
    }

    // MARK: - Content Views
    @ViewBuilder
    private var content: some View {
        // Main content
    }

    private func sectionView() -> some View {
        // Section
    }
}
```

### 10.3 Performance Optimization

**Lazy Loading:**
```swift
LazyVStack(spacing: 16) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

**Image Optimization:**
```swift
AsyncImage(url: imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .shimmer()
}
```

**Tab Caching:**
```swift
struct CachedTabContainer: View {
    @State private var initializedTabs: Set<TabbedItems> = []

    var body: some View {
        ZStack {
            ForEach(TabbedItems.allCases, id: \.self) { tab in
                if initializedTabs.contains(tab) || selectedTab == tab {
                    TabContent(tab: tab)
                        .opacity(selectedTab == tab ? 1 : 0)
                        .onAppear {
                            initializedTabs.insert(tab)
                        }
                }
            }
        }
    }
}
```

### 10.4 State Management

**View State:**
```swift
@State private var isExpanded: Bool = false
@State private var selectedItems: Set<Int> = []
```

**ViewModel State:**
```swift
@Observable
final class ViewModel {
    private(set) var loadingState: LoadState<[Item]> = .notRequested
    private(set) var output: Output?
}
```

**Binding:**
```swift
@Bindable private var viewModel: ViewModel

TextField("Title", text: $viewModel.title)
```

### 10.5 Error Handling

**UI Error States:**
```swift
@ViewBuilder
private func errorView(_ error: Error) -> some View {
    VStack(spacing: 16) {
        Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 48))
            .foregroundColor(.red)

        Text("Error occurred")
            .font(.headline)

        Text(error.localizedDescription)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)

        Button("Retry") {
            Task {
                await viewModel.load()
            }
        }
        .srStyled(.primaryButton)
    }
    .padding()
}
```

### 10.6 Haptic Feedback

**Usage:**
```swift
// Light impact
HapticManager.shared.impact(style: .light)

// Medium impact
HapticManager.shared.impact(style: .medium)

// Success notification
HapticManager.shared.notification(type: .success)

// Selection feedback
HapticManager.shared.selection()
```

**When to use:**
- Button taps (light)
- Toggle switches (light)
- Successful actions (success)
- Errors (error)
- Selection changes (selection)

### 10.7 Keyboard Management

**Usage:**
```swift
@StateObject private var keyboard = KeyboardObserver()

var body: some View {
    content
        .padding(.bottom, keyboard.keyboardHeight)
        .animation(.easeOut, value: keyboard.keyboardHeight)
}
```

### 10.8 Network Monitoring

**Usage:**
```swift
@StateObject private var networkMonitor = NetworkMonitor()

var body: some View {
    content
        .overlay(alignment: .top) {
            if !networkMonitor.isConnected {
                Text("No internet connection")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
            }
        }
}
```

---

## Conclusion

This design system provides a solid foundation for building consistent, accessible, and performant UI in the saerok-iOS app.

**Key Takeaways:**
1. Always use the `srStyled()` pattern for component styling
2. Reuse existing components before creating new ones
3. Follow SwiftUI best practices and conventions
4. Ensure accessibility in all UI components
5. Optimize for performance with lazy loading and caching
6. Maintain consistency across all features

For implementation details, refer to:
- `CLAUDE.md` - Architectural guidelines
- `Sources/Common/SRDesignSystem/` - Component implementations
- Existing Feature implementations for examples

---

**Last Updated:** 2026-04-18
