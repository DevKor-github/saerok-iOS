//
//  FieldGuideSearchView.swift
//  saerok
//
//  Created by HanSeung on 4/18/25.
//


import Foundation
import SwiftData
import SwiftUI

struct FieldGuideSearchView: View {
    
    // MARK:  Dependencies
    
    @Environment(\.injected) private var injected
    @Environment(\.modelContext) private var modelContext
    private var isGuest: Bool { injected.appState[\.authStatus] == .guest }
    
    // MARK: View State
    
    @Query(sort: \Local.RecentSearchEntity.createdAt, order: .reverse)
    private var recentSearchItems: [Local.RecentSearchEntity]
    
    @State private var filterKey: BirdFilter = .init()
    @State private var fieldGuide: [Local.Bird]
    @State private var filteredBirds: [Local.Bird] = []
    @State private var hangulFinder: HangulFinder<Local.Bird>
    @State private var showSeasonSheet = false
    @State private var showHabitatSheet = false
    @State private var showSizeSheet = false
    @FocusState private var isSearchBarFocused: Bool

    // MARK: Navigation
    
    @Binding var path: NavigationPath
    
    // MARK: Init
    
    init(path: Binding<NavigationPath>) {
        self._path = path
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
        .onAppear { isSearchBarFocused = true }
    }
}

private extension FieldGuideSearchView {
    
    enum Layout {
        static let iconSize: CGFloat = 24
        static let horizontalPadding: CGFloat = 18
        static let verticalPadding: CGFloat = 14
        static let textFieldHeight: CGFloat = 44
        static let filterTopPadding: CGFloat = 15
        static let filterBottomPadding: CGFloat = 18
        static let searchItemPadding: CGFloat = 16
        static let recentItemHeight: CGFloat = 55
        static let clearColorHeight: CGFloat = 4
        static let searchSpacing: CGFloat = 2
        static let recentSpacing: CGFloat = 1
        static let hStackSpacing: CGFloat = 19
    }
    
    var searchBarSection: some View {
        HStack {
            Button(action: backButtonTapped) {
                Image.SRIconSet.chevronLeft
                    .frame(.defaultIconSize)
                    .foregroundStyle(.main)
            }
            .buttonStyle(.plain)
            
            TextField("새 이름을 입력해주세요", text: $filterKey.searchText)
                .textFieldDeletable(text: $filterKey.searchText)
        }
        .padding(.vertical, Layout.verticalPadding)
        .padding(.leading, Layout.horizontalPadding)
        .frame(height: Layout.textFieldHeight)
        .srStyled(.textField(isFocused: $isSearchBarFocused, alwaysFocused: true))
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .padding(.top, 7)
    }
    
    @ViewBuilder
    func searchResultSection() -> some View {
        ScrollView {
            if filterKey.searchText.isEmpty {
                VStack(spacing: Layout.recentSpacing) {
                    Color.clear
                        .frame(height: 0)
                    
                    ForEach(recentSearchItems) { search in
                        recentItem(search)
                            .listRowInsets(.init())
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteRecentTapped(search)
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
        .background(Color.whiteGray)
    }
    
    func searchItem(_ bird: Local.Bird) -> some View {
        HStack(spacing: Layout.hStackSpacing) {
            bookmarkButtonSection(bird)
                .frame(width: Layout.iconSize)
            
            Button(action: { searchItemTapped(bird) }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(bird.name)
                            .font(.SRFontSet.body3)
                        Text(bird.scientificName)
                            .font(.SRFontSet.caption1)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image.SRIconSet.chevronRight
                        .frame(.defaultIconSize)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .padding(Layout.searchItemPadding)
        .background(Color.srWhite)
    }
    
    func bookmarkButtonSection(_ bird: Local.Bird) -> some View {
        Button {
            bookmarkButtonTapped(bird)
        } label: {
            (bird.isBookmarked
             ? Image.SRIconSet.bookmarkFilled
             : Image.SRIconSet.bookmarkSecondary)
            .frame(.defaultIconSizeLarge)
            .foregroundStyle(.border)
        }
    }
    
    func recentItem(_ search: Local.RecentSearchEntity) -> some View {
        HStack {
            Button(action: { recentItemTapped(search) }) {
                HStack(spacing: 0) {
                    Text(search.bird.name)
                    Spacer()
                    Text(search.createdAt.toShortString)
                        .foregroundColor(.srGray)
                        .font(.caption)
                }
                .contentShape(Rectangle())
            }
            
            Button(action: { deleteRecentTapped(search) }) {
                Image.SRIconSet.delete
                    .frame(.defaultIconSizeSmall, tintColor: .secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(height: Layout.recentItemHeight)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
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
        path.removeLast()
    }
    
    func bookmarkButtonTapped(_ bird: Local.Bird) {
        Task {
            if !isGuest {
                HapticManager.shared.trigger(.light)
                bird.isBookmarked = try await injected.interactors.fieldGuide.toggleBookmark(birdID: bird.id)
                HapticManager.shared.trigger(.success)
            } else {
                HapticManager.shared.trigger(.error)
            }
        }
    }
    
    func searchItemTapped(_ bird: Local.Bird) {
        path.append(FieldGuideView.Route.birdDetail(bird))
        updateRecentItem(bird)
    }
    
    func recentItemTapped(_ search: Local.RecentSearchEntity) {
        path.append(FieldGuideView.Route.birdDetail(search.bird))
    }
    
    func deleteRecentTapped(_ search: Local.RecentSearchEntity) {
        modelContext.delete(search)
    }
    
    func updateRecentItem(_ bird: Local.Bird) {
        let birdName = bird.name
        let request = FetchDescriptor<Local.RecentSearchEntity>(
            predicate: #Predicate { $0.bird.name == birdName },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        if let existing = try? modelContext.fetch(request).first {
            existing.createdAt = .now
        } else {
            modelContext.insert(Local.RecentSearchEntity(bird: bird))
        }
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
