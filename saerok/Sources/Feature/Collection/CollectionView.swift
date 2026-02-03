//
//  CollectionView.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//


import Combine
import SwiftData
import SwiftUI

enum CollectionRoute: AppRoute {
    case collectionDetail(Int)
    case addCollection
    case notification
}

struct CollectionView: Routable {
    typealias Route = CollectionRoute
    
    // MARK: - Dependencies
    @Environment(\.injected) private var injected: DIContainer
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - Routing
    @State var routingState: Routing = .init()
    
    // MARK: - View State
    @State private var offsetY: CGFloat = 0
    @State private var showPopup: Bool = false
    @State private var viewModel: ViewModel
    
    // MARK: - Init
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        content
            .task { await viewModel.loadPosts() }
            .onReceive(routingUpdate) { routingState = $0 }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .collectionDetail(let id):
                    CollectionDetailView(viewModel: coordinator.makeCollectionDetailViewModel(id: id))
                case .addCollection:
                    CollectionFormView(mode: .add)
                case .notification:
                    NotificationView(viewModel: coordinator.makeNotificationViewModel())
                }
            }
            .onChange(of: routingState.collectionID, initial: true) { _, id in
                guard let id else { return }
                coordinator.push(Route.collectionDetail(id))
            }
            .onChange(of: routingState.addCollection, initial: true) { _, isTrue in
                if isTrue { coordinator.push(Route.addCollection) }
            }
            .onChange(of: routingState.refreshCollections) { _, newID in
                guard newID != nil else { return }
                Task {
                    await viewModel.loadPosts()
                }
            }
            .onChange(of: routingState.scrollToTop) { _, newID in
                guard let _ = newID else { return }
                offsetY = 0
                self.routingState.scrollToTop = nil
            }
            .onChange(of: coordinator.path) { _, path in
                if !path.isEmpty {
                    routingBinding.wrappedValue.collectionID = nil
                }
            }
            .onPreferenceChange(ScrollPreferenceKey.self) { offsetY = $0 }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.loadingState {
        case .notRequested: defaultView()
        case .loading: loadingView()
        case .success(let collections): loadedView(collections)
        case .failure(let error): failedView(error)
        }
    }
}

// MARK: - Loaded Content

private extension CollectionView {
    enum Constants {
        static let navBarSpacerHeight: CGFloat = 64
        static let scrollableID = "CollectionView"
        static let backgroundColor: Color = .red
    }
    
    @ViewBuilder
    func loadedView(_ collections: [Local.CollectionSummary]) -> some View {
        ZStack(alignment: .topLeading) {
            headerBackgroundColor
            
            VStack(spacing: 0) {
                scrollableSection(collections)
            }
        }
        .ignoresSafeArea(.all)
        .onAppear { viewModel.loadUnreadNotification() }
    }
    
    @ViewBuilder
    var headerBackgroundColor: some View {
        Color.srWhite
        Image(.blurTemplate)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .opacity(opacityForScroll(offset: offsetY))
        Rectangle().fill(.thinMaterial).ignoresSafeArea()
    }
    
    var navigationBar: some View {
        ZStack(alignment: .topLeading) {
            NavigationBar(
                trailing: {
                    Button {
                        coordinator.push(Route.notification)
                    } label: {
                        (viewModel.hasUnread ? Image.SRIconSet.bellOn : Image.SRIconSet.bell)
                            .frame(.defaultIconSizeLarge)
                    }
                    .buttonStyle(.icon)
                },
                backgroundColor: .clear
            )
            
            Text(viewModel.birdQuote)
                .font(.SRFontSet.headline1)
                .padding(.horizontal, SRDesignConstant.defaultPadding)
                .padding(.top, 12)
        }
    }
    
    @ViewBuilder
    func scrollableSection(_ collectionSummaries: [Local.CollectionSummary]) -> some View {
        if collectionSummaries.isEmpty {
            Color.clear.frame(height: Constants.navBarSpacerHeight)
            navigationBar
            CollectionEmptyStateView(isGuest: viewModel.isGuestMode, addButtonTapped: addButtonTapped)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    OffsetReaderView().id(Constants.scrollableID).hidden()
                    Color.clear.frame(height: Constants.navBarSpacerHeight)
                    navigationBar
                    VStack(spacing: 0) {
                        CollectionHeaderView(collectionCount: collectionSummaries.count, addButtonTapped: addButtonTapped)
                        StaggeredGrid<_, _, EmptyView>(items: collectionSummaries, columns: 2) { bird in
                            CollectionItemView(bird: bird, tapped: {
                                injected.appState[\.routing.collectionView.collectionID] = bird.id
                            })
                        }
                        .padding(.horizontal)
                        .background(
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(LinearGradient.collectionBackground)
                        )
                    }
                }
                .refreshable { await viewModel.loadPosts() }
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
                    scale: .small,
                    size: .zero,
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
                CollectionEmptyStateView(isGuest: viewModel.isGuestMode, addButtonTapped: {
                    showPopup.toggle()
                })
            }
        }
        .customPopup(isPresented: $showPopup) { alertView }
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

// MARK: - Routable

extension CollectionView {
    struct Routing: Equatable {
        var collectionID: Int?
        var addCollection: Bool = false
        var scrollToTop: UUID?
        var refreshCollections: UUID?
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.collectionView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.collectionView)
    }
}
