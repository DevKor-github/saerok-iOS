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
        case notification
    }
    
    // MARK: - Dependencies
    
    @Environment(\.injected) private var injected: DIContainer
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Routing
    
    @State var routingState: Routing = .init()
    @Binding var path: NavigationPath
    
    // MARK: - View State
    
    @State private var collectionSummaries: [Local.CollectionSummary] = []
    @State private var collectionState: Loadable<Void> = .notRequested
    @State private var offsetY: CGFloat = 0
    @State private var showPopup: Bool = false

    private var isGuestMode: Bool { injected.appState[\.authStatus] == .guest }
    private let birdQuote: String = BirdQuote.random()
    
    // MARK: - Init
    
    init(state: Loadable<Void> = .notRequested, path: Binding<NavigationPath>) {
        self._collectionState = .init(initialValue: state)
        self._path = path
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .onReceive(routingUpdate) { routingState = $0 }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .collectionDetail(let id):
                    CollectionDetailView(collectionID: id, path: $path)
                case .addCollection:
                    CollectionFormView(mode: .add, path: $path)
                case .notification:
                    NotificationView(path: $path)
                }
            }
            .onChange(of: routingState.collectionID, initial: true) { _, id in
                guard let id else { return }
                path.append(Route.collectionDetail(id))
            }
            .onChange(of: routingState.addCollection, initial: true) { _, isTrue in
                if isTrue { path.append(Route.addCollection) }
            }
            .onChange(of: routingState.scrollToTop) { _, newID in
                guard let _ = newID else { return }
                offsetY = 0
                self.routingState.scrollToTop = nil
            }
            .onChange(of: path) { _, path in
                if !path.isEmpty {
                    routingBinding.wrappedValue.collectionID = nil
                }
            }
            .onPreferenceChange(ScrollPreferenceKey.self) { offsetY = $0 }
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
        static let scrollableID = "CollectionView"
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
                        path.append(Route.notification)
                    } label: {
                        Image.SRIconSet.bell
                            .frame(.defaultIconSizeLarge)
                    }
                    .buttonStyle(.icon)
                },
                backgroundColor: .clear
            )
            
            Text(birdQuote)
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
                        StaggeredGrid(items: collectionSummaries.reversed(), columns: 2) { bird in
                            CollectionItem(bird: bird, tapped: {
                                injected.appState[\.routing.collectionView.collectionID] = bird.id
                            })
                        }
                        .padding(.horizontal)
                        .background(
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(maxWidth: .infinity)
                                .frame(height: 451)
                                .background(LinearGradient.collectionBackground)
                        )
                    }
                }
                .refreshable { loadMyCollections() }
                .onChange(of: offsetY) { _, newValue in
                    if newValue == 0 {
                        withAnimation {
                            proxy.scrollTo(Constants.scrollableID, anchor: .top)
                        }
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
                
                Text(bird.birdName ?? "이름 모를 새")
                    .font(.SRFontSet.caption2)
                    .padding(.leading, 8)
            }
        }
        .buttonStyle(.plain)
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
                CollectionEmptyStateView(isGuest: isGuestMode, addButtonTapped: {
                    showPopup.toggle()
                })
            }
        }
        .customPopup(isPresented: $showPopup) { alertView }
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
        var scrollToTop: UUID?
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.collectionView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.collectionView)
    }
}

