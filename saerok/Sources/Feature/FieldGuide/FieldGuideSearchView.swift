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
    
    @Query(sort: \Local.RecentSearchEntity.createdAt, order: .reverse) var recentSearchItems: [Local.RecentSearchEntity]
    @State private var filterKey: BirdFilter = .init()
    @State private var fieldGuide: [Local.Bird]
    @State private var filteredBirds: [Local.Bird] = []
    @State private var showSeasonSheet = false
    @State private var showHabitatSheet = false
    @FocusState private var isSearchBarFocused: Bool
    private var hangulFinder: HangulFinder<Local.Bird>
    
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
        }
        .onChange(of: filterKey.searchText) { _, searchText in
            filteredBirds = hangulFinder.search(searchText)
        }
        .regainSwipeBack()
    }
    
    private var searchBarSection: some View {
        HStack {
            Button {
                path.removeLast()
            } label: {
                Image(.chevronLeft)
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
    
    private func bookmarkButtonSection(_ bird: Local.Bird) -> some View {
        Button {
            bird.isBookmarked.toggle()
        } label: {
            Image(bird.isBookmarked ? .bookmarkFill : .bookmark)
                .font(.system(size: 24, weight: bird.isBookmarked ? .regular : .light))
                .foregroundStyle(bird.isBookmarked ? .main : .gray)
        }
    }
    
    @ViewBuilder
    private func searchResultSection() -> some View {
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
        .background(Color.background)
    }
    
    private func searchItem(_ bird: Local.Bird) -> some View {
        HStack(spacing: 19) {
            Button {
                bird.isBookmarked.toggle()
            } label: {
                Image(bird.isBookmarked ? .bookmarkFill : .bookmark)
                    .font(.system(size: 24, weight: bird.isBookmarked ? .regular : .light))
                    .foregroundStyle(bird.isBookmarked ? .main : .gray)
            }
            .frame(width: 24)
            
            Button {
                path.append(Route.birdDetail(bird))
                modelContext.insert(Local.RecentSearchEntity(bird: bird))
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(bird.name)
                            .font(.SRFontSet.h3)
                        Text(bird.scientificName)
                            .font(.SRFontSet.h4)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(.chevronRight)
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
    
    private func recentItem(_ search: Local.RecentSearchEntity) -> some View {
        HStack {
            Text(search.bird.name)
            Spacer()
            Text(search.createdAt.toShortString)
                .foregroundColor(.gray)
                .font(.caption)
            Button {
                modelContext.delete(search)
            } label: {
                Image.SRIconSet.xmark
                    .frame(.defaultIconSizeVerySmall)
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                seasonFilterButton
                habitatFilterButton
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
    }
    
    var seasonFilterButton: some View {
        let isActive = !filterKey.selectedSeasons.isEmpty
        
        return Button {
            showSeasonSheet.toggle()
        } label: {
            HStack(spacing: 4) {
                Image(.calendar)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16)
                Text(!isActive ? "계절" : filterKey.selectedSeasons.map { $0.rawValue }.joined(separator: " • "))
                    .font(.SRFontSet.h3)
            }
        }
        .srStyled(.filterButton(isActive: isActive))
        .sheetEnumPicker(
            isPresented: $showSeasonSheet,
            title: "계절 선택",
            selection: $filterKey.selectedSeasons,
            presentationDetents: [.fraction(0.3)]
        )
    }
    
    var habitatFilterButton: some View {
        let isActive = !filterKey.selectedHabitats.isEmpty
        
        return Button {
            showHabitatSheet.toggle()
        } label: {
            HStack(spacing: 4) {
                Image(.tree)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16)
                Text(!isActive ? "서식지" : filterKey.selectedHabitats.map { $0.rawValue }.joined(separator: " • "))
                    .font(.SRFontSet.h3)
            }
        }
        .srStyled(.filterButton(isActive: isActive))
        .sheetEnumPicker(
            isPresented: $showHabitatSheet,
            title: "계절 선택",
            selection: $filterKey.selectedHabitats,
            presentationDetents: [.fraction(0.4)]
        )
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
