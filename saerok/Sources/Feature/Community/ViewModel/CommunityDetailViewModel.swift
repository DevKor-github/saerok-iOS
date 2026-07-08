//
//  CommunityDetailViewModel.swift
//  saerok
//
//  Created by HanSeung on 12/9/25.
//

import Foundation
import Combine

extension CommunityDetailView {
    @Observable
    final class ViewModel: ObservableObject {
        let type: CommunityType

        // MARK: State
        private(set) var items: [Local.CommunityItemSummary] = []
        private(set) var page: Int = 1
        private(set) var isLoading: Bool = false
        private(set) var hasNext: Bool = true
        private(set) var didLoad: Bool = false
        private(set) var isGuestMode: Bool = true

        // MARK: Dependencies
        private let interactor: CommunityInteractor
        private let appStore: AppStore
        private let cancelBag = CancelBag()

        // MARK: Config
        private let size: Int = 20

        init(type: CommunityType, interactor: CommunityInteractor, appStore: AppStore) {
            self.type = type
            self.interactor = interactor
            self.appStore = appStore
            self.isGuestMode = appStore[\.authStatus] == .guest

            appStore
                .updates(for: \.authStatus)
                .map { $0 == .guest }
                .removeDuplicates()
                .weakSink(on: self) { viewModel, isGuest in
                    viewModel.isGuestMode = isGuest
                }
                .store(in: cancelBag)
        }

        func initLoginStatus() {
            appStore.send(.requireAuthentication)
        }

        // MARK: Side Effect
        func loadInitialIfNeeded() async {
            guard !didLoad else { return }
            didLoad = true
            await loadInitial()
        }

        private func loadInitial() async {
            page = 1
            hasNext = true
            items = []
            await loadMore()
        }

        func loadMore() async {
            guard !isLoading, hasNext else { return }
            isLoading = true

            do {
                let newItems = try await interactor.fetchItems(
                    type: type,
                    page: page,
                    size: size
                )

                items.append(contentsOf: newItems)

                if newItems.count < size {
                    hasNext = false
                } else {
                    page += 1
                }
            } catch {
                hasNext = false
            }

            isLoading = false
        }
    }
}
