//
//  CommunityView.swift
//  saerok
//
//  Created by HanSeung on 9/15/25.
//

import Combine
import SwiftUI

enum CommunityRoute: AppRoute {
    case communityType(type: CommunityType)
    case detailFromFeed(id: Int)
    case detailFromProfile(id: Int)
    case detailFromSearch(id: Int)
    case postDetail(postId: Int)
    case other(id: Int)
    case addCollection
}

struct CommunityView: View {
    typealias Route = CommunityRoute

    // MARK: Dependency
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.showToast) var showToast

    // MARK: ViewModel
    @Bindable private var viewModel: ViewModel

    // MARK: UI State
    @State private var showLoginPopup: Bool = false
    @State private var showPostingView: Bool = false
    @State private var offsetY: CGFloat = 0
    @FocusState private var isFocused: Bool
    @Binding private var showFloatingMenu: Bool

    // MARK: Init
    init(viewModel: ViewModel, showFloatingMenu: Binding<Bool>) {
        self.viewModel = viewModel
        self._showFloatingMenu = showFloatingMenu
    }

    var body: some View {
        content
            .onAppear { Task { await viewModel.loadPosts() } }
            .navigationDestination(for: Route.self) { route in routeView(for: route) }
            .onPreferenceChange(ScrollPreferenceKey.self) { newValue in
                let clampedNew = max(min(newValue, 0), -100)
                let clampedOld = max(min(self.offsetY, 0), -100)
                guard abs(clampedNew - clampedOld) > 0.5 else { return }
                self.offsetY = newValue
            }
            .refreshable { Task { await viewModel.refreshPosts() } }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .notRequested:
            defaultView
        case .loading:
            ProgressView()
        case .success:
            loadedView
        case .failure:
            failedView
        }
    }
}

// MARK: - Navigation
private extension CommunityView {
    @ViewBuilder
    func routeView(for route: Route) -> some View {
        switch route {
        case .communityType(let type) where type == .board:
            FreeBoardListViewWrapper(factory: coordinator.factory)
        case .communityType(let type):
            CommunityDetailViewWrapper(factory: coordinator.factory, type: type)
        case .detailFromFeed(let id):
            CollectionDetailViewWrapper(factory: coordinator.factory, id: id, entrySource: .communityFeed)
        case .detailFromProfile(let id):
            CollectionDetailViewWrapper(factory: coordinator.factory, id: id, entrySource: .userProfile)
        case .detailFromSearch(let id):
            CollectionDetailViewWrapper(factory: coordinator.factory, id: id, entrySource: .communitySearch)
        case .postDetail(let postId):
            CommunityPostDetailViewWrapper(factory: coordinator.factory, postId: postId)
        case .other(let id):
            UserSummaryViewWrapper(factory: coordinator.factory, id: id)
        case .addCollection:
            CollectionFormViewWrapper(factory: coordinator.factory, mode: .add)
        }
    }
}

// MARK: - Loaded View
private extension CommunityView {
    enum Constants {
        static let navBarSpacerHeight: CGFloat = 64
        static let bottomPadding: CGFloat = 114
    }

    var loadedView: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.srWhite

            LinearGradient.srPointGradient
                .opacity(opacityForScroll(offset: offsetY))
                .opacity(viewModel.isModeIdle ? 1 : 0)

            VStack(spacing: 0) {
                Color.clear.frame(height: Constants.navBarSpacerHeight)
                searchBarSection

                ZStack(alignment: .top) {
                    scrollableSection
                        .opacity(viewModel.isModeIdle ? 1 : 0)
                        .allowsHitTesting(viewModel.isModeIdle)

                    CommunitySearchResultsView(
                        searchText: viewModel.text,
                        searchMainItems: viewModel.searchMainItems,
                        mode: viewModel.mode,
                        searchCase: $viewModel.searchCase,
                    )
                    .opacity(viewModel.isModeIdle ? 0 : 1)
                    .allowsHitTesting(!viewModel.isModeIdle)
                }
            }
        }
        .modifier(
            FloatingMenuModifier(
                postAction: { showPostingView.toggle() },
                saerokAction: {
                    if viewModel.isGuestMode {
                        showLoginPopup = true
                    } else {
                        coordinator.push(Route.addCollection)
                    }
                },
                bottomOffset: 102,
                showMenu: $showFloatingMenu,
                isHidden: $showPostingView
            )
        )
        .sheet(isPresented: $showPostingView) {
            PostingView(
                nickname: viewModel.currentUserNickname,
                profileImageUrl: viewModel.currentUserProfileImageUrl,
                isPresented: $showPostingView,
                onPost: { content in
                    do {
                        try await viewModel.createFreeboardPost(content: content)
                        showToast(
                            .init(
                                type: .success,
                                message: "게시글을 올렸어요.",
                                placementOffset: -120,
                                transitionOffset: 160,
                                duration: 3.0
                            )
                        )
                    } catch {
                        showToast(
                            .init(
                                type: .failure,
                                message: "게시글 업로드에 실패했어요.",
                                placementOffset: -120,
                                transitionOffset: 160,
                                duration: 3.0
                            )
                        )
                    }
                }
            )
        }
        .ignoresSafeArea(.all)
        .onTapGesture {
            if !viewModel.isModeIdle { isFocused = false }
        }
        .srPopup(
            isPresented: $showLoginPopup,
            config: showLoginPopup ? loginPopupConfig : nil
        )
    }

    // MARK: Search Bar
    var searchBarSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchInputBar(
                tintColor: .pointtext,
                placeHolder: "사용자, 새 이름을 검색해보세요!",
                isModeIdle: viewModel.mode == .idle,
                text: $viewModel.text,
                isFocused: $isFocused,
                mode: $viewModel.mode,
                onTap: { viewModel.mode = .searching },
                onTextChange: { viewModel.updateSearchText($0) }
            )
            .equatable()
            .padding(.bottom, viewModel.isModeIdle ? 7 : 0)

            if !viewModel.isModeIdle {
                CommunityFilterBar(selected: $viewModel.searchCase)
            }
        }
        .overlay(alignment: .bottom) {
            Divider()
                .background(Color.whiteGray)
                .frame(height: 1)
                .opacity(1 - opacityForScroll(offset: offsetY))
        }
        .background(
            Color.srWhite
                .opacity(1 - opacityForScroll(offset: offsetY))
        )
        .onChange(of: isFocused) { _, new in if new { viewModel.mode = .searching } }
        .onChange(of: viewModel.mode) { _, new in if new == .idle { isFocused = false } }
        .onChange(of: viewModel.searchCase) { viewModel.perfomrSearch() }
    }

    // MARK: - Scrollable Content
    var scrollableSection: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    OffsetReaderView().id("community-scrollable")

                    FreeBoardCarouselSection(
                        posts: Array(viewModel.mainItems.recentFreeBoardPosts.prefix(5)),
                        onPostTap: { coordinator.push(Route.postDetail(postId: $0)) },
                        onCTATap: { coordinator.push(Route.communityType(type: .board)) }
                    )
                    .padding(.bottom, 14)
                    
                    Group {
                        BannerView()
                            .cornerRadius(10)
                            .padding(.vertical, 15)
                        VStack(spacing: 44) {
                            boardSections
                            suggestionListSection
                            listSection(.recent)
                            listSection(.popular)
                            Color.clear.frame(height: 70)
                        }
                    }
                    .background(Color.srWhite)
                }
            }
        }
    }

    // MARK: Sections
    var boardSections: some View {
        VStack(alignment: .leading, spacing: 0) {
            boardSection(title: "새록 모아보기") {
                iconButton(type: .recent, icon: .commentCommunity, background: .accent)
                iconButton(type: .popular, icon: .fire, background: .fire)
                iconButton(type: .suggestion, icon: .unknown, background: .pointtext)
            }
            Divider()
                .hidden()
                .frame(height: 1)
                .background(Color.srLightGray)
            boardSection(title: "자유게시판") {
                iconButton(type: .board, icon: .post, background: .srGreen)
            }
        }
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.srLightGray, lineWidth: 1))
        .padding(.horizontal, 24)
    }

    func boardSection(
        title: String,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.SRFontSet.caption1)
                .foregroundStyle(.srGray)
                .padding(.bottom, 10)
            VStack(alignment: .leading, spacing: 13) {
                content()
            }
        }
        .padding(15)
    }

    var suggestionListSection: some View {
        VStack(spacing: 15) {
            headerWithButton(type: .suggestion)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    Color.clear
                        .frame(width: 17)
                    ForEach(viewModel.mainItems.pendingCollections) { item in
                        Button {
                            coordinator.push(Route.detailFromFeed(id: item.id))
                        } label: {
                            CommunitySuggestionCell(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                    Color.clear.frame(width: 17)
                }
                .padding(.vertical, 8) // 카드 그림자가 잘리지 않도록 여백 확보
            }
            .padding(.vertical, -8) // 추가한 여백만큼 상쇄해 섹션 프레임은 유지
        }
    }

    func listSection(_ type: CommunityType) -> some View {
        let items: [Local.CommunityItemSummary] = {
            switch type {
            case .popular: viewModel.mainItems.popularCollections
            case .recent: viewModel.mainItems.recentCollections
            default: []
            }
        }()

        return VStack(spacing: 18) {
            headerWithButton(type: type)
            VStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        coordinator.push(Route.detailFromFeed(id: item.id))
                    } label: {
                        CommunityCell(item: item, type: type)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    var addButton: some View {
        Button {
            if viewModel.isGuestMode {
                showLoginPopup = true
            } else {
                coordinator.push(Route.addCollection)
            }
        } label: {
            Image(viewModel.isGuestMode ? .floatingButtonInactive : .floatingButton)
                .resizable()
                .frame(width: 61, height: 61)
                .shadow(color: .black.opacity(0.25), radius: 5)
        }
    }

    var loginPopupConfig: PopupConfig {
        PopupConfig(
            title: "로그인이 필요한 기능이에요",
            message: "로그인하고 더 많은 기능을 사용해보세요!",
            buttons: .double(
                .init(
                    title: "취소",
                    style: .bordered,
                    action: {
                        showLoginPopup = false
                    }
                ),
                .init(
                    title: "로그인",
                    style: .confirm,
                    action: {
                        showLoginPopup = false
                        viewModel.initLoginStatus()
                    }
                )
            )
        )
    }

    private func headerWithButton(type: CommunityType) -> some View {
        HStack {
            Text(type.title).font(.SRFontSet.subtitle1_3)
            Spacer()
            Button { coordinator.push(Route.communityType(type: type)) } label: {
                HStack(spacing: 8) {
                    Text("더보기")
                        .font(.SRFontSet.caption0)
                        .foregroundStyle(.srDarkGray)
                    Image.SRIconSet.chevronRight
                        .frame(.small, tintColor: .srDarkGray)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func iconButton(type: CommunityType, icon: Image.SRIconSet, background: Color) -> some View {
        Button { coordinator.push(Route.communityType(type: type)) } label: {
            HStack(spacing: 9) {
                icon
                    .frame(.default, tintColor: icon == .unknown ? .srWhite : nil)
                    .padding(4)
                    .background(background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(type.title)
                    .font(.SRFontSet.body2_3)
                Text("N")
                    .font(.custom(Pretendard.bold.rawValue, size: 7))
                    .foregroundStyle(.white)
                    .background(
                        Rectangle()
                          .foregroundColor(.clear)
                          .frame(width: 11, height: 11)
                          .background(Color.iconRed)
                          .cornerRadius(3)
                    )
                Spacer()
                Image.SRIconSet.chevronRight
                    .frame(.xSmall)
                    .foregroundStyle(.srDarkGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Carousel Section (isolated state to prevent parent re-renders)

private struct FreeBoardCarouselSection: View {
    let posts: [Local.FreeBoardPostSummary]
    let onPostTap: (Int) -> Void
    let onCTATap: () -> Void

    @State private var displayIndex: Int = 0

    var body: some View {
        let dotCount = posts.count + 1
        VStack(spacing: 3) {
            FreeBoardInfiniteCarouselView(
                posts: posts,
                displayIndex: $displayIndex,
                onPostTap: onPostTap,
                onCTATap: onCTATap
            )
            .frame(height: FreeBoardInfiniteCarouselView.Const.itemHeight)

            if dotCount > 1 {
                HStack(spacing: 5) {
                    ForEach(0..<dotCount, id: \.self) { i in
                        Circle()
                            .fill(displayIndex == i ? .splash : Color.srLightGray)
                            .frame(width: 7, height: 7)
                    }
                }
            }
        }
    }
}

private extension CommunityView {
    var defaultView: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.srWhite
            LinearGradient.srPointGradient
                .opacity(opacityForScroll(offset: offsetY))
            VStack {
                Color.clear
                    .frame(height: Constants.navBarSpacerHeight)
                Spacer()
            }
        }
        .ignoresSafeArea(.all)
    }

    var failedView: some View {
        ProgressView()
            .background(Color.srWhite)
    }
}

// MARK: - Navigation Destination Wrappers

struct FreeBoardListViewWrapper: View {
    let factory: ViewModelFactory
    @State private var viewModel: FreeBoardListView.ViewModel

    init(factory: ViewModelFactory) {
        self.factory = factory
        _viewModel = State(wrappedValue: factory.makeFreeBoardListViewModel())
    }

    var body: some View { FreeBoardListView(viewModel: viewModel) }
}

struct CommunityDetailViewWrapper: View {
    let factory: ViewModelFactory
    let type: CommunityType
    @State private var viewModel: CommunityDetailView.ViewModel

    init(factory: ViewModelFactory, type: CommunityType) {
        self.factory = factory
        self.type = type
        _viewModel = State(wrappedValue: factory.makeCommunityDetailViewModel(for: type))
    }

    var body: some View { CommunityDetailView(viewModel: viewModel) }
}

struct CollectionDetailViewWrapper: View {
    let factory: ViewModelFactory
    let id: Int
    let entrySource: EntrySource
    @State private var viewModel: CollectionDetailView.ViewModel

    init(factory: ViewModelFactory, id: Int, entrySource: EntrySource) {
        self.factory = factory
        self.id = id
        self.entrySource = entrySource
        _viewModel = State(wrappedValue: factory.makeCollectionDetailViewModel(id: id, entrySource: entrySource))
    }

    var body: some View { CollectionDetailView(viewModel: viewModel) }
}

struct CommunityPostDetailViewWrapper: View {
    let factory: ViewModelFactory
    let postId: Int
    @State private var viewModel: CommunityPostDetailView.ViewModel

    init(factory: ViewModelFactory, postId: Int) {
        self.factory = factory
        self.postId = postId
        _viewModel = State(wrappedValue: factory.makeCommunityPostDetailViewModel(postId: postId))
    }

    var body: some View { CommunityPostDetailView(viewModel: viewModel) }
}

struct UserSummaryViewWrapper: View {
    let factory: ViewModelFactory
    let id: Int
    @State private var viewModel: UserSummaryView.ViewModel

    init(factory: ViewModelFactory, id: Int) {
        self.factory = factory
        self.id = id
        _viewModel = State(wrappedValue: factory.makeUserSummaryViewModel(id))
    }

    var body: some View { UserSummaryView(viewModel: viewModel) }
}
