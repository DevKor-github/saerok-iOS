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
    case collectionDetailFromNotiCenter(Int)
    case collectionDetailFromDeepLink(Int)
    case addCollection(bird: Local.Bird?)
    case notification
    case directToBoardDetail(Int)
}

struct CollectionView: View {
    typealias Route = CollectionRoute
    
    // MARK: - Dependencies
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var coordinator: AppCoordinator
        
    // MARK: - View State
    @Bindable private var viewModel: ViewModel
    @State private var offsetY: CGFloat = 0
    @State private var showPopup: Bool = false
    @State private var scrollToTopTrigger: Bool = false
    
    // MARK: - Init
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        content
            .onAppear { Task { await viewModel.loadPosts() } }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .collectionDetail(let id):
                    CollectionDetailView(viewModel: coordinator.makeCollectionDetailViewModel(id: id, entrySource: .`self`))
                case .collectionDetailFromNotiCenter(let id):
                    CollectionDetailView(viewModel: coordinator.makeCollectionDetailViewModel(id: id, entrySource: .notiCenter))
                case .collectionDetailFromDeepLink(let id):
                    CollectionDetailView(viewModel: coordinator.makeCollectionDetailViewModel(id: id, entrySource: .deeplink))
                case .addCollection(let bird):
                    CollectionFormView(viewModel: coordinator.makeCollectionFormViewModel(mode: .add, bird: bird))
                case .notification:
                    NotificationView(viewModel: coordinator.makeNotificationViewModel())
                case .directToBoardDetail(let id):
                    BoardDetailView(id: id, viewModel: coordinator.makeBoardViewModel())
                }
            }
            .onChange(of: viewModel.output, initial: true) { _, output in
                guard let output = output else { return }

                switch output {
                case .scrollToTop:
                    scrollToTopTrigger.toggle()
                case .navigateToDetail(let id):
                    coordinator.push(Route.collectionDetailFromDeepLink(id))
                }
                viewModel.resetOutput()
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
                    Button { coordinator.push(Route.notification) } label: {
                        (viewModel.hasUnread ? Image.SRIconSet.bellOn : Image.SRIconSet.bell)
                            .frame(.large)
                    }
                    .srStyled(.iconButton)
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
                        StaggeredGrid<_, _, EmptyView>(items: collectionSummaries, columns: 2) { collection in
                            CollectionItemView(collection, tapped: {
                                coordinator.push(Route.collectionDetail(collection.id))
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
                .refreshable { await viewModel.refresh() }
                .onChange(of: scrollToTopTrigger) { _, _ in
                    withAnimation { proxy.scrollTo(Constants.scrollableID, anchor: .top) }
                }
            }
        }
    }
    
    func birdView(for collection: Local.CollectionSummary) -> some View {
        Button { coordinator.push(Route.collectionDetail(collection.id)) } label: {
            VStack(alignment: .leading) {
                ReactiveAsyncImage(
                    url: collection.imageURL ?? "",
                    scale: .small,
                    size: .zero,
                    downsampling: true
                )
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text(collection.birdName ?? "이름 모를 새")
                    .font(.SRFontSet.caption2)
                    .padding(.leading, 8)
            }
        }
        .buttonStyle(.plain)
    }
    
    var loginRequiredPopupConfig: PopupConfig {
        PopupConfig(
            title: "로그인이 필요한 기능이에요",
            message: "로그인하고 더 많은 기능을 사용해보세요!",
            buttons: .double(
                .init(
                    title: "취소",
                    style: .bordered,
                    action: {
                        showPopup = false
                    }
                ),
                .init(
                    title: "로그인",
                    style: .confirm,
                    action: {
                        showPopup = false
                        viewModel.changeStatusToLogout()
                    }
                )
            )
        )
    }
    
    func addButtonTapped() { coordinator.push(Route.addCollection(bird: nil)) }
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
        .srPopup(
            isPresented: $showPopup,
            config: showPopup ? loginRequiredPopupConfig : nil
        )
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
