//
//  FieldGuideView.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Combine
import SwiftData
import SwiftUI

struct FieldGuideView: Routable {
    enum Route: Hashable {
        case search
        case birdDetail(Local.Bird)
    }
    
    // MARK: - Dependencies
    
    @Environment(\.injected) private var injected: DIContainer
    
    // MARK: - Routable
    
    @State var routingState: Routing = .init()
    
    // MARK: - Navigation
    
    @Binding var navigationPath: NavigationPath
    
    // MARK: - View State
    
    @State private var fieldGuide: [Local.Bird]
    @State private var fieldGuideState: Loadable<Void>
    @State private var filterKey: BirdFilter = .init()
    @State private var showSeasonSheet = false
    @State private var showHabitatSheet = false
    @State private var showSizeSheet = false
    @State private var showPopup: Bool = false
    @State private var offsetY: CGFloat = 0

    // MARK: - Init
    
    init(state: Loadable<Void> = .notRequested, path: Binding<NavigationPath>) {
        self.fieldGuide = []
        self._fieldGuideState = .init(initialValue: state)
        self._navigationPath = path
    }
    
    var body: some View {
        content
            .query(key: filterKey, results: $fieldGuide) { filterKey in
                Query(
                    filter: filterKey.build(),
                    sort: \Local.Bird.name
                )
            }
            .onReceive(routingUpdate) { self.routingState = $0 }
            .navigationDestination(for: FieldGuideView.Route.self) { route in
                switch route {
                case .search:
                    FieldGuideSearchView(path: $navigationPath)
                case .birdDetail(let bird):
                    BirdDetailView(bird: bird, path: $navigationPath)
                }
            }
            .onChange(of: routingState.birdName, initial: true, { _, name in
                guard let name,
                      let bird = fieldGuide.first(where: { $0.name == name })
                else { return }
                navigateToBirdDetail(bird)
            })
            .onChange(of: routingState.scrollToTop) { _, newID in
                guard let _ = newID else { return }
                offsetY = 0
                self.routingState.scrollToTop = nil
            }
            .onChange(of: navigationPath, { _, path in
                if !path.isEmpty {
                    routingBinding.wrappedValue.birdName = nil
                }
            })
            .onPreferenceChange(ScrollPreferenceKey.self) { value in
                self.offsetY = value
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch fieldGuideState {
        case .notRequested, .isLoading:
            defaultView()
        case .loaded:
            loadedView()
        case let .failed(error):
            failedView(error)
        }
    }
}

// MARK: - Loaded Content

private extension FieldGuideView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let headerHeight: CGFloat = 100
        static let headerTopPadding: CGFloat = 16
        static let iconBackgroundSize: CGFloat = 40
        static let navBarSpacerHeight: CGFloat = 64
        static let scrollableID: String = "scrollable"
    }
    
    @ViewBuilder
    func loadedView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            Color.srWhite
            
            LinearGradient.srGradient
                .opacity(opacityForScroll(offset: offsetY))
            
            VStack(spacing: 0) {
                Color.clear.frame(height: Constants.navBarSpacerHeight)
                navigationBar
                scrollableSection
            }
            
            scrollToTopButton
        }
        .ignoresSafeArea(.all)
        .customPopup(isPresented: $showPopup) { alertView }
    }
    
    var navigationBar: some View {
        NavigationBar(
            leading: {
                Text("도감")
                    .font(.SRFontSet.headline1)
            },
            trailing: {
                HStack(spacing: 7) {
                    bookmarkFilterButton
                    searchButton
                }
            },
            backgroundColor: .clear
        )
    }
    
    var bookmarkFilterButton: some View {
        Button(action: bookmarkTapped) {
            (filterKey.isBookmarked
             ? Image.SRIconSet.bookmarkFilled
             : Image.SRIconSet.bookmark)
            .frame(.defaultIconSizeLarge, tintColor: filterKey.isBookmarked ? .pointtext : .black)
        }
        .srStyled(.iconButton)
    }
    
    var searchButton: some View {
        Button(action: searchButtonTapped) {
            Image.SRIconSet.search
                .frame(.defaultIconSizeLarge)
        }
        .srStyled(.iconButton)
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text("585")
                .font(.SRFontSet.heavy)
                .fontWeight(.semibold)
                .foregroundStyle(.splash)
            Text("종의 새가 도감에 등록되어 있어요.")
                .font(.SRFontSet.caption1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Constants.headerHeight)
        .padding(SRDesignConstant.defaultPadding)
    }
    
    var scrollableSection: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    OffsetReaderView()
                        .id(Constants.scrollableID)
                    headerSection
                    FilterBar(
                        showSeasonSheet: $showSeasonSheet,
                        showHabitatSheet: $showHabitatSheet,
                        showSizeSheet: $showSizeSheet,
                        filterKey: $filterKey
                    )
                    .padding(.vertical, Constants.headerTopPadding)
                    .background(.srLightGray)
                    BirdGridView(
                        birds: fieldGuide,
                        onTap: { bird in
                            injected.appState[\.routing.fieldGuideView.birdName] = bird.name
                        },
                        showPopup: $showPopup
                    )
                }
            }
            .onChange(of: offsetY) { _, newValue in
                if newValue == 0 && routingState.scrollToTop != nil {
                    withAnimation {
                        proxy.scrollTo(Constants.scrollableID, anchor: .top)
                    }
                }
            }
        }
    }
    
    var scrollToTopButton: some View {
        Button {
            offsetY = 0
        } label: {
            Image.SRIconSet.upper
                .frame(.defaultIconSizeLarge)
        }
        .srStyled(.iconButton)
        .padding(.bottom, 114)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
    }
    
    var alertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "로그인이 필요한 기능이에요",
            message: "로그인하고 더 많은 기능을 사용해보세요!",
            leading: .init(
                title: "취소",
                action: {
                    showPopup = false
                },
                style: .bordered
            ),
            trailing: .init(
                title: "로그인",
                action: {
                    showPopup = false
                    injected.appState[\.authStatus] = .notDetermined
                },
                style: .confirm
            ),
            center: nil
        )
    }
}

// MARK: - Loading Content

private extension FieldGuideView {
    func defaultView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            Color.srWhite
            
            LinearGradient.srGradient
                .opacity(opacityForScroll(offset: offsetY))
            
            VStack(spacing: 0) {
                Color.clear.frame(height: Constants.navBarSpacerHeight)
                navigationBar
                Spacer()
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            if !fieldGuide.isEmpty {
                fieldGuideState = .loaded(())
            }
            loadFieldGuide()
        }
    }
    
    func loadingView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    func failedView(_ error: Error) -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
}

// MARK: - Side Effects & Helper Methods

private extension FieldGuideView {
    func loadFieldGuide() {
        $fieldGuideState.load {
            try? await injected.interactors.fieldGuide.refreshFieldGuide()
        }
        
        if injected.appState[\.authStatus] != .guest {
            Task {
                try? await injected.interactors.fieldGuide.refreshBookmarks()
            }
        }
    }
    
    func bookmarkTapped() {
        filterKey.isBookmarked.toggle()
    }
    
    func searchButtonTapped() {
        navigationPath.append(Route.search)
    }
    
    func navigateToBirdDetail(_ bird: Local.Bird) {
        navigationPath.append(FieldGuideView.Route.birdDetail(bird))
    }
}

// MARK: - Routable

extension FieldGuideView {
    struct Routing: Equatable {
        var birdName: String?
        var scrollToTop: UUID?
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.fieldGuideView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.fieldGuideView)
    }
    
    var tapUpdate: AnyPublisher<ContentView.Routing, Never> {
        injected.appState.updates(for: \.routing.contentView)
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    appDelegate.rootView
}

