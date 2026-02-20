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
                        print("싱크! \(id)")
                    }
                
                appState
                    .updates(for: \.routing.collectionView.refreshCollections)
                    .dropFirst()
                    .weakSink(on: self) { viewModel, _ in
                        Task { await viewModel.loadPosts() }
                    }
            }
        }
        
        func loadPosts() async {
            if !isGuestMode &&
                ((loadingState == .notRequested) || loadingState.inError)
            {
                loadingState = await loadingState.load {
                    try await collectionInteractor.fetchMyCollections()
                }
            }
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

