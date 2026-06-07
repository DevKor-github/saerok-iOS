//
//  CollectionViewModel.swift
//  saerok
//
//  Created by HanSeung on 1/28/26.
//

import Foundation
import Combine

extension CollectionView {
    struct Routing: Equatable {
        var collectionID: Int?
        var scrollToTop: UUID?
        var refreshCollections: UUID?
    }
}

extension CollectionView {
    @Observable
    final class ViewModel {
        enum Output: Equatable {
            case navigateToDetail(id: Int)
            case openNotificationView
            case scrollToTop(UUID)
        }
        
        // MARK: State
        private(set) var loadingState: LoadState<[Local.CollectionSummary]> = .notRequested
        private(set) var hasUnread: Bool = false
        private(set) var output: Output?
        let birdQuote: String = BirdQuote.random()
        
        // MARK: Dependencies
        private let appStore: AppStore
        private let collectionInteractor: CollectionInteractor
        private let userInteractor: UserInteractor
        
        private(set) var isGuestMode: Bool
        
        @ObservationIgnored private let cancelBag: CancelBag
        
        init(appStore: AppStore, collectionInteractor: CollectionInteractor, userInteractor: UserInteractor) {
            self.appStore = appStore
            self.collectionInteractor = collectionInteractor
            self.userInteractor = userInteractor
            self.cancelBag = .init()
            self.isGuestMode = appStore[\.authStatus] == .guest
            
            cancelBag.collect {
                appStore.events
                    .filter { $0 == .collectionScrollToTop }
                    .weakSink(on: self) { viewModel, _ in
                        viewModel.output = .scrollToTop(UUID())
                    }

                appStore.events
                    .compactMap { guard case .collectionDetailRequested(let id) = $0 else { return nil }; return id }
                    .weakSink(on: self) { viewModel, id in
                        viewModel.output = .navigateToDetail(id: id)
                    }

                appStore.events
                    .filter { $0 == .collectionsRefreshRequested }
                    .weakSink(on: self) { viewModel, _ in
                        Task { await viewModel.refresh() }
                    }

                appStore.events
                    .filter { $0 == .notificationView }
                    .weakSink(on: self) { viewModel, _ in
                        viewModel.output = .openNotificationView
                    }

                appStore
                    .updates(for: \.authStatus)
                    .map { $0 == .guest }
                    .removeDuplicates()
                    .weakSink(on: self) { viewModel, isGuest in
                        viewModel.isGuestMode = isGuest
                    }
            }
        }
        
        // 최초 진입 및 에러 재시도 — .loading 상태를 거쳐 전체 뷰를 교체
        func loadPosts() async {
            guard !isGuestMode && ((loadingState == .notRequested) || loadingState.inError) else { return }
            loadingState = await loadingState.load {
                try await collectionInteractor.fetchMyCollections()
            }
        }

        // pull-to-refresh / 등록·삭제 후 갱신 — .loading 전환 없이 데이터만 교체
        func refresh() async {
            guard !isGuestMode else { return }
            do {
                let collections = try await collectionInteractor.fetchMyCollections()
                loadingState = .success(collections)
            } catch { }
        }
        
        func loadUnreadNotification() {
            if !isGuestMode {
                Task {
                    if let unread = try? await userInteractor.hasUnreadNotifications() {
                        hasUnread = unread
                    }
                }
            }
        }
        
        func changeStatusToLogout() {
            appStore.send(.requireAuthentication)
        }
        
        func resetOutput() {
            output = nil
        }
    }
}
