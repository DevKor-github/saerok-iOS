//
//  CommunityView.swift
//  saerok
//
//  Created by HanSeung on 9/15/25.
//

import Combine
import SwiftUI

struct CommunityView: Routable {
    enum Route: Hashable {
        case communityType(type: CommunityType)
        case detail(id: Int)
        case other(id: Int)
    }
    
    // MARK: - Dependencies
    
    @Environment(\.injected) private var injected
    
    // MARK: - Routable
    
    @State var routingState: Routing = .init()
    
    // MARK: - Navigation
    
    @Binding var path: NavigationPath
    
    // MARK: - View State
    
    @State private var mainItems: Local.CommunityMainItems = .init()
    @State private var searchMainItems: Local.CommunitySearchMainItems = .init(collections: [], users: [])
    
    @State private var loadingState: Loadable<Void> = .notRequested
    @State private var showPopup: Bool = false
    @State private var offsetY: CGFloat = 0
    @State private var hasLoadedOnce = false
    
    @State private var text: String = ""
    @State var searchCase: CommunitySearchCase = .all
    @State private var mode: SearchInputBar.Mode = .idle
    private var isModeIdle: Bool { mode == .idle }
    @FocusState private var isFocused: Bool
    
    @State private var searchDebounceTask: Task<Void, Error>? = nil

    // MARK: - Init
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        content
            .onReceive(routingUpdate) { routingState = $0 }
            .navigationDestination(for: CommunityView.Route.self) { route in
                switch route {
                case .communityType(let type):
                    CommunityDetailView(type: type, path: $path)
                case .detail(let id):
                    CollectionDetailView(collectionID: id, path: $path)
                case .other(let id):
                    UserSummaryView(path: $path, userID: id)
                }
            }
            .onChange(of: path) { _, path in
                if !path.isEmpty {
                    routingBinding.wrappedValue.scrollToTop = nil
                }
            }
            .onChange(of: searchCase) { _, _ in
                Task {
                    await performSearch()
                }
            }
            .onPreferenceChange(ScrollPreferenceKey.self) { value in
                self.offsetY = value
            }
            .customPopup(isPresented: $showPopup) { alertView }
    }
    
    @ViewBuilder
    private var content: some View {
        switch loadingState {
        case .notRequested:
            defaultView()
        case .isLoading:
            loadingView()
        case .loaded:
            loadedView()
        case .failed:
            failedView()
        }
    }
}

// MARK: - Loaded Content
private extension CommunityView {
    enum Constants {
        static let navBarSpacerHeight: CGFloat = 64
        static let headerTopPadding: CGFloat = 16
        static let listSpacing: CGFloat = 10
        static let scrollableID: String = "community-scrollable"
        static let bottomPadding: CGFloat = 114
    }
    
    func loadedView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            Color.srWhite
            
            LinearGradient.srPointGradient
                .opacity(opacityForScroll(offset: offsetY))
                .opacity(isModeIdle ? 1 : 0)
            
            VStack(spacing: 0) {
                Color.clear.frame(height: Constants.navBarSpacerHeight)
                searchBarSection
                ZStack(alignment: .top) {
                    scrollableSection
                        .opacity(isModeIdle ? 1 : 0)
                        .allowsHitTesting(isModeIdle)
                    
                    CommunitySearchResultsView(
                        text: text,
                        searchMainItems: searchMainItems,
                        path: $path,
                        mode: $mode,
                        searchCase: $searchCase
                    )
                    .opacity(isModeIdle ? 0 : 1)
                    .allowsHitTesting(!isModeIdle)
                }
            }
        }
        .ignoresSafeArea(.all)
        .onTapGesture {
            if !isModeIdle { isFocused = false }
        }
        .onAppear {
            if hasLoadedOnce {
                Task { await refreshPosts() }
            } else {
                hasLoadedOnce = true
            }
        }
    }
    
    var searchBarSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchInputBar(
                tintColor: .pointtext,
                placeHolder: "사용자, 새 이름을 검색해보세요!",
                isModeIdle: isModeIdle,
                text: $text,
                isFocused: $isFocused,
                mode: $mode,
                onTap: {
                    mode = .searching
                },
                onTextChange: { _ in
                    debounceTask {
                        await performSearch()
                    }
                }
            )
            .padding(.bottom, isModeIdle ? 20 : 0)

            if !isModeIdle {
                CommunityFilterBar(selected: $searchCase)
            }
        }
        .overlay(alignment: .bottom) {
            Divider()
                .background(Color.whiteGray)
                .frame(height: 1)
                .opacity(1 -  opacityForScroll(offset: offsetY))
        }
        .background(Color.srWhite
            .opacity(1 - opacityForScroll(offset: offsetY))
        )
        .onChange(of: isFocused) { _, new in
            if new {
                mode = .searching
            }
        }
        .onChange(of: mode) { _, new in
            if new == .idle {
                isFocused = false
            }
        }
    }
    
    var scrollableSection: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    OffsetReaderView()
                        .id(Constants.scrollableID)
                    
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
            .refreshable { await refreshPosts() }
            .onChange(of: offsetY) { _, newValue in
                if newValue == 0 && routingState.scrollToTop != nil {
                    withAnimation {
                        proxy.scrollTo(Constants.scrollableID, anchor: .top)
                    }
                }
            }
        }
    }
    
    var boardSection: some View {
        VStack(alignment: .leading, spacing:13) {
            iconButton(type: .recent, icon: .commentCommunity, background: .accent)
            iconButton(type: .popular, icon: .fire, background: .fire)
            iconButton(type: .suggestion, icon: .unknown, background: .pointtext)
        }
        .padding(15)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .inset(by: 0.5)
                .stroke(Color.srLightGray, lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .padding(.top, 13)
    }
    
    var suggestionListSection: some View {
        VStack(spacing: 15) {
            headerWithButton(type: .suggestion)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    Color.clear.frame(width: 17)
                    ForEach(mainItems.pendingCollections) { item in
                        Button {
                            path.append(Route.detail(id: item.id))
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
            case .popular: mainItems.popularCollections
            case .recent: mainItems.recentCollections
            default: mainItems.popularCollections
            }
        }()
        
        return VStack(spacing: 18) {
            headerWithButton(type: type)
            VStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        path.append(Route.detail(id: item.id))
                    } label: {
                        CommunityCell(item: item, type: type)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var alertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "로그인이 필요한 기능이에요",
            message: "로그인하고 더 많은 기능을 사용해보세요!",
            leading: .init(
                title: "취소",
                action: { showPopup = false },
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
    
    private func headerWithButton(type: CommunityType) -> some View {
        HStack {
            Text(type.title)
                .font(.SRFontSet.subtitle1_3)
            Spacer()
            Button {
                path.append(Route.communityType(type: type))
            } label: {
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
        Button {
            path.append(Route.communityType(type: type))
        } label: {
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
        .contentShape(Rectangle())
    }
}

// MARK: - Loading/Failed
private extension CommunityView {
    func defaultView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            Color.srWhite
            
            LinearGradient.srPointGradient
                .opacity(opacityForScroll(offset: offsetY))
            
            VStack(spacing: 0) {
                Color.clear.frame(height: Constants.navBarSpacerHeight)
                Spacer()
            }
        }
        .ignoresSafeArea(.all)
        .onAppear(perform: loadPosts)
    }
    
    func loadingView() -> some View {
        ProgressView()
    }
    
    func failedView() -> some View {
        VStack { Text("불러오기에 실패했어요") }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.srWhite)
    }
}

// MARK: - Side Effects & Helpers
private extension CommunityView {
    func loadPosts() {
        $loadingState.load {
            let items = try await injected.interactors.community.fetchMain()
            self.mainItems = items
        }
    }
    
    func refreshPosts() async {
        guard let items = try? await injected.interactors.community.fetchMain() else { return }
        
        await MainActor.run { self.mainItems = items }
    }
    
    func debounceTask(delay: UInt64 = 800_000_000, action: @escaping @Sendable () async throws -> Void) {
        searchDebounceTask?.cancel()
        searchDebounceTask = Task {
            try await Task.sleep(nanoseconds: delay)
            try Task.checkCancellation()
            try await action()
        }
    }
    
    func performSearch() async {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            await MainActor.run {
                self.searchMainItems = .init(collections: [], users: [])
            }
            
            return
        }
        do {
            self.searchMainItems = try await injected.interactors.community.search(query, searchCase: searchCase)
            self.mode = .resultShown
        } catch {
            await MainActor.run {
                self.searchMainItems = .init(collections: [], users: [])
                self.mode = .searching
            }
        }
    }
}

// MARK: - Routable
extension CommunityView {
    struct Routing: Equatable {
        var scrollToTop: UUID?
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.communityView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.communityView)
    }
}

// MARK: - UI Components

// MARK: - Preview
#Preview {
    @Previewable @State var path: NavigationPath = .init()
    CommunityView(path: $path)
}

