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
    case detail(id: Int)
    case other(id: Int)
    case addCollection
}

struct CommunityView: View {
    typealias Route = CommunityRoute

    // MARK: Dependency
    @EnvironmentObject private var coordinator: AppCoordinator

    // MARK: ViewModel
    @Bindable private var viewModel: ViewModel

    // MARK: UI State
    @State private var showLoginPopup: Bool = false
    @State private var offsetY: CGFloat = 0
    @FocusState private var isFocused: Bool
    
    // MARK: Init
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .onAppear { Task { await viewModel.loadPosts() } }
            .navigationDestination(for: Route.self) { route in routeView(for: route) }
            .customPopup(isPresented: $showLoginPopup) { alertView }
            .onPreferenceChange(ScrollPreferenceKey.self) { self.offsetY = $0 }
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
        case .communityType(let type):
            CommunityDetailView(viewModel: coordinator.makeCommunityDetailViewModel(for: type))
        case .detail(let id):
            CollectionDetailView(viewModel: coordinator.makeCollectionDetailViewModel(id: id))
        case .other(let id):
            UserSummaryView(viewModel: coordinator.makeUserSummaryViewModel(id))
        case .addCollection:
            CollectionFormView(viewModel: coordinator.makeCollectionFormViewModel(mode: .add))
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

            addButton
                .padding(.bottom, 106)
                .padding(.trailing, 24)
        }
        .ignoresSafeArea(.all)
        .onTapGesture {
            if !viewModel.isModeIdle { isFocused = false }
        }
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
            .padding(.bottom, viewModel.isModeIdle ? 20 : 0)

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

                    suggestionListSection
                        .padding(.bottom, 26)

                    VStack(spacing: 44) {
                        VStack(spacing: 15) {
                            boardSection
                            BannerView()
                        }
                        listSection(.recent)
                        listSection(.popular)
                        Color.clear.frame(height: 70)
                    }
                    .background(Color.srWhite)
                }
            }
        }
    }

    // MARK: Sections
    var boardSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            iconButton(type: .recent, icon: .commentCommunity, background: .accent)
            iconButton(type: .popular, icon: .fire, background: .fire)
            iconButton(type: .suggestion, icon: .unknown, background: .pointtext)
        }
        .padding(15)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.srLightGray, lineWidth: 1))
        .padding(.horizontal, 24)
        .padding(.top, 13)
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
                            coordinator.push(Route.detail(id: item.id))
                        } label: {
                            CommunitySuggestionCell(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                    Color.clear.frame(width: 17)
                }
            }
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
                        coordinator.push(Route.detail(id: item.id))
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

    var alertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "로그인이 필요한 기능이에요",
            message: "로그인하고 더 많은 기능을 사용해보세요!",
            leading: .init(title: "취소", action: { showLoginPopup = false }, style: .bordered),
            trailing: .init(title: "로그인", action: {
                showLoginPopup = false
                viewModel.initLoginStatus()
            }, style: .confirm),
            center: nil
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
                        .frame(.defaultIconSizeSmall, tintColor: .srDarkGray)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func iconButton(type: CommunityType, icon: Image.SRIconSet, background: Color) -> some View {
        Button { coordinator.push(Route.communityType(type: type)) } label: {
            HStack(spacing: 9) {
                icon
                    .frame(.defaultIconSize, tintColor: icon == .unknown ? .srWhite : nil)
                    .padding(4)
                    .background(background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(type.title)
                    .font(.SRFontSet.body2_3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
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
