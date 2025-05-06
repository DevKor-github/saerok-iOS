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
    
    // MARK:  Init
    
    init(path: Binding<NavigationPath>) {
        self._path = path
        self.fieldGuide = []
        hangulFinder = .init(items: [], keySelector: { $0.name })
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
    }
}

private extension FieldGuideSearchView {
    var searchBarSection: some View {
        HStack {
            Button {
                path.removeLast()
            } label: {
                Image.SRIconSet.chevronLeft
                    .frame(.defaultIconSize)
                    .foregroundStyle(.main)
            }
            .buttonStyle(.plain)
            
            TextField("새 이름을 입력해주세요", text: $filterKey.searchText)
                .textFieldDeletable(text: $filterKey.searchText)
        }
        .padding(.vertical, 14)
        .padding(.leading, 18)
        .frame(height: 44)
        .srStyled(.textField(isFocused: $isSearchBarFocused))
        .padding(.horizontal, SRDesignConstant.defaultPadding)
    }
    
    func bookmarkButtonSection(_ bird: Local.Bird) -> some View {
        Button {
            bird.isBookmarked.toggle()
        } label: {
            (bird.isBookmarked
             ? Image.SRIconSet.bookmarkFilled.frame(.defaultIconSize)
             : Image.SRIconSet.bookmark.frame(.defaultIconSize))
        }
    }
    
    @ViewBuilder
    func searchResultSection() -> some View {
        ScrollView {
            if filterKey.searchText.isEmpty {
                VStack(spacing: 1){
                    Color.clear
                        .frame(height: 0)
                    
                    ForEach(recentSearchItems) { search in
                        recentItem(search)
                            .listRowInsets(.init())
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear
                        .frame(height: 4)
                    
                    VStack(spacing: 2) {
                        ForEach(filteredBirds, id: \.name) { bird in
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
        HStack(spacing: 19) {
            Button {
                bird.isBookmarked.toggle()
            } label: {
                (bird.isBookmarked
                 ? Image.SRIconSet.bookmarkFilled.frame(.defaultIconSize)
                 : Image.SRIconSet.bookmark.frame(.defaultIconSize))
            }
            .frame(width: 24)
            
            Button {
                path.append(Route.birdDetail(bird))
                updateRecentItem(bird)
            } label: {
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
        .padding(SRDesignConstant.defaultPadding)
        .background(Color.srWhite)
    }
    
    func recentItem(_ search: Local.RecentSearchEntity) -> some View {
        HStack {
            Button {
                path.append(Route.birdDetail(search.bird))
            } label: {
                HStack(spacing: 0) {
                    Text(search.bird.name)
                    Spacer()
                    Text(search.createdAt.toShortString)
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .contentShape(Rectangle())
            }
            
            Button {
                modelContext.delete(search)
            } label: {
                Image.SRIconSet.xmark
                    .frame(.defaultIconSizeSmall)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 55)
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
        .padding(.top, 15)
        .padding(.bottom, 18)
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
