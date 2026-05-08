//
//  CollectionSearchView.swift
//  saerok
//
//  Created by HanSeung on 4/27/25.
//


import SwiftData
import SwiftUI

extension CollectionSearchView {
    @Observable
    final class ViewModel {
        var filterKey: BirdFilter = .init()
        private(set) var filteredBirds: [Local.Bird] = []
        @ObservationIgnored private var hangulFinder: HangulFinder<Local.Bird> = .init(items: [], keySelector: { $0.name })
        @ObservationIgnored private var searchDebounceTask: Task<Void, Never>?

        func updateFieldGuide(_ newDataSet: [Local.Bird]) {
            hangulFinder.reInitialize(newDataSet)
            filteredBirds = hangulFinder.search(filterKey.searchText)
        }

        func scheduleSearch() {
            searchDebounceTask?.cancel()
            searchDebounceTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard let self, !Task.isCancelled, !filterKey.searchText.isEmpty else { return }
                filteredBirds = hangulFinder.search(filterKey.searchText)
            }
        }
    }
}

struct CollectionSearchView: View {

    // MARK:  Dependencies

    @Environment(\.injected) private var injected
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: View State

    @State private var viewModel = ViewModel()
    @State private var fieldGuide: [Local.Bird] = []  // SwiftData query 결과 바인딩은 @State 필요
    @FocusState private var isSearchBarFocused: Bool

    let onSelect: (Local.Bird) -> Void

    var body: some View {
        content
            .query(key: viewModel.filterKey, results: $fieldGuide) { filterKey in
                Query(
                    filter: filterKey.build(),
                    sort: \Local.Bird.name
                )
            }
            .onChange(of: fieldGuide) { _, newDataSet in
                viewModel.updateFieldGuide(newDataSet)
            }
            .onChange(of: viewModel.filterKey, initial: true) { _, _ in
                viewModel.scheduleSearch()
            }
            .onAppear {
                isSearchBarFocused = true
            }
            .regainSwipeBack()
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
                dismiss()
            } label: {
                Image.SRIconSet.chevronLeft.frame(.small)
            }
        })
        .frame(height: 66)
    }
    
    var searchBarSection: some View {
        @Bindable var vm = viewModel
        return TextField("새 이름을 입력해주세요", text: $vm.filterKey.searchText)
            .textFieldDeletable(text: $vm.filterKey.searchText)
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
                        viewModel.filterKey.searchText.isEmpty
                            ? fieldGuide.filter { $0.isBookmarked }
                            : viewModel.filteredBirds, id: \.name
                    ) { bird in
                        searchItem(bird)
                            .listRowInsets(.init())
                    }
                }
            }
        }
        .background(.srLightGray)
    }
    
    func searchItem(_ bird: Local.Bird) -> some View {
        HStack(spacing: 19) {
            Button { } label: {
                (bird.isBookmarked
                 ? Image.SRIconSet.bookmarkFilled
                 : Image.SRIconSet.bookmark)
                .frame(.large)
            }
            .frame(width: 24)
            
            Button {
                onSelect(bird)
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
                        .frame(.default)
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
