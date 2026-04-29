//
//  CollectionViewModel.swift
//  saerok
//
//  Created by HanSeung on 1/28/26.
//

import Foundation

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
            case scrollToTop(UUID)
        }
        
        // MARK: State
        private(set) var loadingState: LoadState<[Local.CollectionSummary]> = .notRequested
        private(set) var hasUnread: Bool = false
        private(set) var output: Output?
        let birdQuote: String = BirdQuote.random()
        
        // MARK: Dependencies
        private let appState: Store<AppState>
        private let collectionInteractor: CollectionInteractor
        private let userInteractor: UserInteractor
        
        var isGuestMode: Bool { appState[\.authStatus] == .guest }
        
        @ObservationIgnored private let cancelBag: CancelBag
        
        init(appState: Store<AppState>, collectionInteractor: CollectionInteractor, userInteractor: UserInteractor) {
            self.appState = appState
            self.collectionInteractor = collectionInteractor
            self.userInteractor = userInteractor
            self.cancelBag = .init()
            
            cancelBag.collect {
                appState
                    .updates(for: \.routing.collectionView.scrollToTop)
                    .compactMap { $0 }
                    .weakSink(on: self) { viewModel, _ in
                        viewModel.output = .scrollToTop(UUID())
                    }
                
                appState
                    .updates(for: \.routing.collectionView.collectionID)
                    .compactMap { $0 }
                    .weakSink(on: self) { viewModel, id in
                        viewModel.output = .navigateToDetail(id: id)
                    }
                
                appState
                    .updates(for: \.routing.collectionView.refreshCollections)
                    .dropFirst()
                    .weakSink(on: self) { viewModel, _ in
                        Task { await viewModel.refresh() }
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
            appState[\.authStatus] = .notDetermined
        }
        
        func resetOutput() {
            output = nil
        }
    }
}

