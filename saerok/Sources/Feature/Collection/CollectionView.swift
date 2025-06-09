//
//  CollectionView.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//


import Combine
import SwiftData
import SwiftUI

struct CollectionView: Routable {
    enum Route: Hashable {
        case collectionDetail(Int)
        case addCollection
    }
    
    // MARK: - Dependencies
    
    @Environment(\.injected) private var injected: DIContainer
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Routing
    
    @State var routingState: Routing = .init()
    @Binding var navigationPath: NavigationPath
    
    // MARK: - View State
    
    private var isGuestMode: Bool { injected.appState[\.authStatus] == .guest }
    @State private var collectionSummaries: [Local.CollectionSummary] = []
    @State private var collectionState: Loadable<Void> = .notRequested
    @State private var offsetY: CGFloat = 0
    
    // MARK: - Init
    
    init(state: Loadable<Void> = .notRequested, path: Binding<NavigationPath>) {
        self._collectionState = .init(initialValue: state)
        self._navigationPath = path
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .onReceive(routingUpdate) { routingState = $0 }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .collectionDetail(let id):
                    CollectionDetailView(collectionID: id, path: $navigationPath)
                case .addCollection:
                    CollectionFormView(mode: .add, path: $navigationPath)
                }
            }
            .onChange(of: routingState.collectionID, initial: true) { _, id in
                guard let id else { return }
                navigationPath.append(Route.collectionDetail(id))
            }
            .onChange(of: routingState.addCollection, initial: true) { _, isTrue in
                if isTrue { navigationPath.append(Route.addCollection) }
            }
            .onChange(of: navigationPath) { _, path in
                if !path.isEmpty {
                    routingBinding.wrappedValue.collectionID = nil
                }
            }
            .onPreferenceChange(ScrollPreferenceKey.self) { offsetY = $0 }
            .onAppear { loadMyCollections() }
    }
    
    @ViewBuilder
    private var content: some View {
        switch collectionState {
        case .notRequested: defaultView()
        case .isLoading: loadingView()
        case .loaded: loadedView()
        case .failed(let error): failedView(error)
        }
    }
}

// MARK: - Loaded Content

private extension CollectionView {
    enum Constants {
        static let navBarSpacerHeight: CGFloat = 64
        static let scrollableID = "scrollable"
    }
    
    @ViewBuilder
    func loadedView() -> some View {
        ZStack(alignment: .topLeading) {
            headerBackgroundColor
            VStack(spacing: 0) {
                scrollableSection
            }
        }
        .ignoresSafeArea(.all)
    }
    
    @ViewBuilder
    var headerBackgroundColor: some View {
        Color.srWhite
        Image(.blurTemplate).opacity(opacityForScroll(offset: offsetY))
        Rectangle().fill(.thinMaterial).ignoresSafeArea()
    }
    
    var navigationBar: some View {
        ZStack(alignment: .topLeading) {
            NavigationBar(
                trailing: {
                    Button {
                        // TODO: 검색 기능
                    } label: {
                        Image.SRIconSet.search.frame(.defaultIconSizeLarge)
                    }
                    .buttonStyle(.icon)
                },
                backgroundColor: .clear
            )
            
            Text("어떤 새를\n관찰해볼까요?")
                .font(.SRFontSet.headline1)
                .padding(.horizontal, SRDesignConstant.defaultPadding)
                .padding(.top, 12)
        }
    }
    
    @ViewBuilder
    var scrollableSection: some View {
        if collectionSummaries.isEmpty {
            Color.clear.frame(height: Constants.navBarSpacerHeight)
            navigationBar
            CollectionEmptyStateView(isGuest: isGuestMode, addButtonTapped: addButtonTapped)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    OffsetReaderView().id(Constants.scrollableID).hidden()
                    Color.clear.frame(height: Constants.navBarSpacerHeight)
                    navigationBar
                    VStack(spacing: 0) {
                        CollectionHeaderView(collectionCount: collectionSummaries.count, addButtonTapped: addButtonTapped)
                        
                        StaggeredGrid(items: collectionSummaries, columns: 2) { bird in
                            birdView(for: bird)
                        }
                        .padding(.horizontal)
                        .background(Color.srWhite)
                    }
                }
                .refreshable { loadMyCollections() }
                .onChange(of: offsetY) { _, newValue in
                    if newValue == 0 {
                        withAnimation { proxy.scrollTo(Constants.scrollableID, anchor: .top) }
                    }
                }
            }
        }
    }
    
    func birdView(for bird: Local.CollectionSummary) -> some View {
        Button {
            injected.appState[\.routing.collectionView.collectionID] = bird.id
        } label: {
            VStack(alignment: .leading) {
                ReactiveAsyncImage(
                    url: bird.imageURL ?? "",
                    scale: .medium,
                    quality: 0.8,
                    downsampling: true
                )
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text(bird.birdName ?? "어디선가 본 새")
                    .font(.SRFontSet.caption2)
                    .padding(.leading, 8)
            }
        }
        .buttonStyle(.plain)
    }
    
    func addButtonTapped() {
        routingState.addCollection = true
        injected.appState[\.routing.addCollectionItemView.selectedBird] = nil
    }
}

// MARK: - Loading & Error Views

private extension CollectionView {
    func defaultView() -> some View {
        ZStack(alignment: .topLeading) {
            headerBackgroundColor
            VStack(spacing: 0) {
                Color.clear.frame(height: Constants.navBarSpacerHeight)
                navigationBar
                CollectionEmptyStateView(isGuest: isGuestMode, addButtonTapped: {})
            }
        }
        .onAppear {
            if !isGuestMode {
                collectionState = .loaded(())
                loadMyCollections()
            }
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

// MARK: - Side Effects

private extension CollectionView {
    func loadMyCollections() {
        if !isGuestMode {
            $collectionState.load {
                do {
                    collectionSummaries = try await injected.interactors.collection.fetchMyCollections()
                } catch {
                    print("콜렉션에러: \(error)")
                }
            }
        }
    }
}

// MARK: - Routable

extension CollectionView {
    struct Routing: Equatable {
        var collectionID: Int?
        var addCollection: Bool = false
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.collectionView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.collectionView)
    }
}

// MARK: - Preview

//#Preview {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    appDelegate.rootView
//}

#Preview(body: {
    @State var path: NavigationPath = .init()
    CollectionView(path: $path)
})
