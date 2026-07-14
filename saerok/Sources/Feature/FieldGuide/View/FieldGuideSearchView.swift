//
//  FieldGuideSearchView.swift
//  saerok
//
//  Created by HanSeung on 4/18/25.
//


import Foundation
import Combine
import SwiftData
import SwiftUI


extension FieldGuideSearchView {
    @Observable
    final class ViewModel {
        private let appStore: AppStore
        private let interactor: FieldGuideInteractor
        private(set) var isGuest: Bool
        private(set) var recentSearches: [Local.RecentBirdSearch] = []
        private let cancelBag = CancelBag()

        init(appStore: AppStore, interactor: FieldGuideInteractor) {
            self.appStore = appStore
            self.interactor = interactor
            self.isGuest = appStore[\.authStatus] == .guest

            appStore
                .updates(for: \.authStatus)
                .map { $0 == .guest }
                .removeDuplicates()
                .weakSink(on: self) { viewModel, isGuest in
                    viewModel.isGuest = isGuest
                }
                .store(in: cancelBag)
        }

        func toggleBookmark(birdId: Int) async throws -> Bool {
            try await interactor.toggleBookmark(birdID: birdId)
        }

        /// 최근 검색 기록 로드. `@Query` 자동 갱신을 대체하므로 저장·삭제 후 반드시 재호출한다.
        @MainActor
        func loadRecentSearches() async {
            recentSearches = (try? await interactor.recentSearches()) ?? []
        }

        @MainActor
        func saveRecentSearch(birdID: Int) {
            Task {
                try? await interactor.saveRecentSearch(birdID: birdID)
                await loadRecentSearches()
            }
        }

        @MainActor
        func deleteRecentSearch(id: UUID) {
            Task {
                try? await interactor.deleteRecentSearch(id: id)
                await loadRecentSearches()
            }
        }

        /// 최근 검색 기록 → 상세 이동을 위한 `Local.Bird` 재조회.
        @MainActor
        func loadBird(id: Int) async throws -> Local.Bird {
            try await interactor.loadBirdDetails(birdID: id)
        }
    }
}

struct FieldGuideSearchView: View {
    // MARK: View State
    @State private var viewModel: ViewModel
    @State private var filterKey: BirdFilter = .init()
    @State private var fieldGuide: [Local.Bird]
    @State private var filteredBirds: [Local.Bird] = []
    @State private var hangulFinder: HangulFinder<Local.Bird>
    @State private var showSeasonSheet = false
    @State private var showHabitatSheet = false
    @State private var showSizeSheet = false
    @FocusState private var isSearchBarFocused: Bool
    
    // MARK:  Dependencies
    @EnvironmentObject private var coordinator: AppCoordinator

    // MARK: Init
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.fieldGuide = []
        self.hangulFinder = .init(items: [], keySelector: { $0.name })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            searchBarSection
            filterButtonSection
            searchResultSection()
        }
        .query(key: filterKey, results: $fieldGuide) { filterKey in
            Query(
                filter: filterKey.build(),
                sort: \Local.Bird.name
            )
        }
        .onChange(of: fieldGuide) { _, newDataSet in
            hangulFinder.reInitialize(newDataSet)
            filteredBirds = hangulFinder.search(filterKey.searchText)
        }
        .onChange(of: filterKey) { _, filterKey in
            filteredBirds = hangulFinder.search(filterKey.searchText)
        }
        .regainSwipeBack()
        .onAppear {
            if filterKey.searchText.isEmpty {
                isSearchBarFocused = true
            }
            Task { await viewModel.loadRecentSearches() }
        }
    }
}

private extension FieldGuideSearchView {
    
    enum Layout {
        static let iconSize: CGFloat = 22
        static let horizontalPadding: CGFloat = 18
        static let verticalPadding: CGFloat = 14
        static let textFieldHeight: CGFloat = 44
        static let filterTopPadding: CGFloat = 15
        static let filterBottomPadding: CGFloat = 18
        static let searchItemPadding: CGFloat = 17
        static let recentItemHeight: CGFloat = 55
        static let clearColorHeight: CGFloat = 2
        static let searchSpacing: CGFloat = 1
        static let recentSpacing: CGFloat = 1
        static let hStackSpacing: CGFloat = 18
    }
    
    var searchBarSection: some View {
        HStack {
            Button(action: backButtonTapped) {
                Image.SRIconSet.chevronLeft
                    .frame(.default)
                    .foregroundStyle(.main)
            }
            .buttonStyle(.plain)
            
            TextField("새 이름을 입력해주세요", text: $filterKey.searchText)
                .textFieldDeletable(text: $filterKey.searchText)
        }
        .padding(.vertical, Layout.verticalPadding)
        .padding(.leading, Layout.horizontalPadding)
        .frame(height: 44)
        .srStyled(.textField(isFocused: $isSearchBarFocused, alwaysFocused: true))
        .padding(.horizontal, SRSpacing.screenHorizontal)
        .padding(.top, 7)
    }
    
    @ViewBuilder
    func searchResultSection() -> some View {
        if !filterKey.searchText.isEmpty && filteredBirds.isEmpty {
            emptySearchResultView
        } else {
            ScrollView {
                if filterKey.searchText.isEmpty {
                    VStack(spacing: Layout.recentSpacing) {
                        Color.clear
                            .frame(height: 0)

                        ForEach(viewModel.recentSearches) { search in
                            recentItem(search)
                                .listRowInsets(.init())
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.deleteRecentSearch(id: search.id)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.clear
                            .frame(height: Layout.clearColorHeight)

                        LazyVStack(spacing: Layout.searchSpacing) {
                            ForEach(filteredBirds, id: \.id) { bird in
                                searchItem(bird)
                                    .listRowInsets(.init())
                            }
                        }
                    }
                }
            }
            .background(Color.srLightGray)
        }
    }

    var emptySearchResultView: some View {
        ZStack(alignment: .top) {
            Color.srLightGray

            VStack(spacing: 5) {
                Text("이곳은 고요한 숲처럼 조용하네요.")
                    .font(.SRFontSet.subtitle1_2)
                    .multilineTextAlignment(.center)
                Text("새록에 등록되어있지 않은 새예요.")
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Image(.logoBack)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.srWhite)
                    .frame(width: 116, height: 128)
                    .padding(.top, 8)
            }
            .padding(.top, 68)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
    }
    
    func searchItem(_ bird: Local.Bird) -> some View {
        HStack(spacing: Layout.hStackSpacing) {
            bookmarkButtonSection(bird)
                .frame(width: Layout.iconSize)
            
            Button(action: { searchItemTapped(bird) }) {
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(bird.name)
                            .font(.SRFontSet.body3)
                        Text(bird.scientificName)
                            .font(.SRFontSet.caption1)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image.SRIconSet.chevronRight
                        .frame(.default)
                        .foregroundStyle(.black)
                }
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 17)
        .padding(.horizontal, 26)
        .background(Color.srWhite)
    }
    
    func bookmarkButtonSection(_ bird: Local.Bird) -> some View {
        Button {
            bookmarkButtonTapped(bird)
        } label: {
            (bird.isBookmarked
             ? Image.SRIconSet.bookmarkFilled
             : Image.SRIconSet.bookmarkSecondary)
            .frame(.large)
            .foregroundStyle(.border)
        }
    }
    
    func recentItem(_ search: Local.RecentBirdSearch) -> some View {
        HStack {
            Button(action: { recentItemTapped(search) }) {
                HStack(spacing: 0) {
                    Text(search.birdName)
                    Spacer()
                    Text(search.createdAt.toShortString)
                        .foregroundColor(.srGray)
                        .font(.caption)
                }
                .contentShape(Rectangle())
            }

            Button(action: { viewModel.deleteRecentSearch(id: search.id) }) {
                Image.SRIconSet.delete
                    .frame(.small, tintColor: .secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(height: Layout.recentItemHeight)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, SRSpacing.screenHorizontal)
        .background(Color.srWhite)
    }
    
    var filterButtonSection: some View {
        FilterBar(
            showSeasonSheet: $showSeasonSheet,
            showHabitatSheet: $showHabitatSheet,
            showSizeSheet: $showSizeSheet,
            filterKey: $filterKey
        )
        .padding(.top, Layout.filterTopPadding)
        .padding(.bottom, Layout.filterBottomPadding)
    }
}

// MARK: - Actions

private extension FieldGuideSearchView {
    func backButtonTapped() {
        coordinator.pop()
    }
    
    func bookmarkButtonTapped(_ bird: Local.Bird) {
        Task {
            if !viewModel.isGuest {
                HapticManager.shared.trigger(.light)
                bird.isBookmarked = try await viewModel.toggleBookmark(birdId: bird.id)
                HapticManager.shared.trigger(.success)
            } else {
                HapticManager.shared.trigger(.error)
            }
        }
    }
    
    func searchItemTapped(_ bird: Local.Bird) {
        coordinator.push(FieldGuideView.Route.birdDetail(bird))
        viewModel.saveRecentSearch(birdID: bird.id)
    }

    func recentItemTapped(_ search: Local.RecentBirdSearch) {
        Task {
            guard let bird = try? await viewModel.loadBird(id: search.birdId) else { return }
            coordinator.push(FieldGuideView.Route.birdDetail(bird))
        }
    }
}
