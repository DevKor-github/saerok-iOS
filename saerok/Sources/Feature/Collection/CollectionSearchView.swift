//
//  CollectionSearchView.swift
//  saerok
//
//  Created by HanSeung on 4/27/25.
//


import SwiftData
import SwiftUI

struct CollectionSearchView: View {
    
    // MARK:  Dependencies
    
    @Environment(\.injected) private var injected
    @Environment(\.modelContext) private var modelContext
    
    // MARK: View State
        
    @State private var filterKey: BirdFilter = .init()
    @State private var fieldGuide: [Local.Bird]
    @State private var filteredBirds: [Local.Bird] = []
    @State private var hangulFinder: HangulFinder<Local.Bird>
    @State private var searchDebounceTask: Task<Void, Never>? = nil

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
        content
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
            .onChange(of: filterKey, initial: true) { _, newKey in
                searchTask(newKey)
            }
            .onAppear {
                isSearchBarFocused = true
            }
            .regainSwipeBack()
    }
}

private extension CollectionSearchView {
    func searchTask(_ newKey: BirdFilter) {
        searchDebounceTask?.cancel()
        searchDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !Task.isCancelled && !newKey.searchText.isEmpty {
                filteredBirds = hangulFinder.search(filterKey.searchText)
            }
        }
    }
}

private extension CollectionSearchView {
    var content: some View {
        VStack(spacing: 0) {
            navigationBar
            searchBarSection
            searchResultSection()
        }
    }
    
    var navigationBar: some View {
        NavigationBar(center: {
            Text("이름 찾기")
                .font(.SRFontSet.subtitle2)
        }, leading: {
            Button {
                path.removeLast()
            } label: {
                Image.SRIconSet.chevronLeft.frame(.defaultIconSizeSmall)
            }
        })
        .frame(height: 66)
    }
    
    var searchBarSection: some View {
        TextField("새 이름을 입력해주세요", text: $filterKey.searchText)
            .textFieldDeletable(text: $filterKey.searchText)
            .padding(.vertical, 14)
            .padding(.leading, 18)
            .frame(height: 44)
            .srStyled(.textField(isFocused: $isSearchBarFocused))
            .padding(.horizontal, SRDesignConstant.defaultPadding)
            .padding(.bottom, 14)
    }
    
    @ViewBuilder
    func searchResultSection() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear
                    .frame(height: 4)
                
                VStack(spacing: 2) {
                    ForEach(
                        filterKey.searchText.isEmpty
                            ? fieldGuide.filter { $0.isBookmarked }
                            : filteredBirds, id: \.name
                    ) { bird in
                        searchItem(bird)
                            .listRowInsets(.init())
                    }
                }
            }
        }
        .background(Color.whiteGray)
    }
    
    func searchItem(_ bird: Local.Bird) -> some View {
        HStack(spacing: 19) {
            Button { } label: {
                (bird.isBookmarked
                 ? Image.SRIconSet.bookmarkFilled
                 : Image.SRIconSet.bookmark)
                .frame(.defaultIconSizeLarge)
            }
            .frame(width: 24)
            
            Button {
                injected.appState[\.routing.addCollectionItemView.selectedBird] = bird
                path.removeLast()
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
}
