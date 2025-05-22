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

    @State var navigationPath = NavigationPath()

    // MARK: - View State

    @State private var fieldGuide: [Local.Bird]
    @State private var fieldGuideState: Loadable<Void>
    @State private var filterKey: BirdFilter = .init()
    @State private var showSeasonSheet = false
    @State private var showHabitatSheet = false
    @State private var showSizeSheet = false
    @State private var offsetY: CGFloat = 0

    // MARK: - Init

    init(state: Loadable<Void> = .notRequested) {
        self.fieldGuide = []
        self._fieldGuideState = .init(initialValue: state)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .query(key: filterKey, results: $fieldGuide) { filterKey in
                    Query(
                        filter: filterKey.build(),
                        sort: \Local.Bird.name
                    )
                }
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
    }

    @ViewBuilder
    private var content: some View {
        switch fieldGuideState {
        case .notRequested:
            defaultView()
        case .isLoading:
            loadingView()
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
        static let headerTopPadding: CGFloat = 20
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
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .search:
                FieldGuideSearchView(path: $navigationPath)
            case .birdDetail(let bird):
                BirdDetailView(bird, path: $navigationPath)
            }
        }
        .onChange(of: routingState.birdName, initial: true, { _, name in
            guard let name,
                  let bird = fieldGuide.first(where: { $0.name == name })
            else { return }
            navigateToBirdDetail(bird)
        })
        .onChange(of: navigationPath, { _, path in
            if !path.isEmpty {
                routingBinding.wrappedValue.birdName = nil
            }
        })
        .onPreferenceChange(ScrollPreferenceKey.self) { value in
            self.offsetY = value
        }
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
            .frame(.defaultIconSizeLarge)
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
            Text("504")
                .font(.SRFontSet.heavy)
                .fontWeight(.semibold)
                .foregroundStyle(.splash)
            Text("종의 새가 도감에 준비되어있어요.")
                .font(.SRFontSet.caption1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Constants.headerHeight)
        .padding(SRDesignConstant.defaultPadding)
    }

    var scrollableSection: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
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
                    .padding(.top, Constants.headerTopPadding)
                    .background(.whiteGray)
                    BirdGridView(
                        birds: fieldGuide,
                        onTap: { bird in
                            injected.appState[\.routing.fieldGuideView.birdName] = bird.name
                        }
                    )
                }
            }
            .onChange(of: offsetY) { _, newValue in
                if newValue == 0 {
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
}

// MARK: - Loading Content

private extension FieldGuideView {
    func defaultView() -> some View {
        Text("")
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
            print("새 로드완료")
        }
    }

    func bookmarkTapped() {
        filterKey.isBookmarked.toggle()
    }

    func searchButtonTapped() {
        navigationPath.append(Route.search)
    }

    func navigateToBirdDetail(_ bird: Local.Bird) {
        navigationPath.append(Route.birdDetail(bird))
    }
}

// MARK: - Routable

extension FieldGuideView {
    struct Routing: Equatable {
        var birdName: String?
    }

    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.fieldGuideView)
    }

    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.fieldGuideView)
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    appDelegate.rootView
}
