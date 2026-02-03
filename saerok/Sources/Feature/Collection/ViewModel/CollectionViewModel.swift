//
//  CollectionViewModel.swift
//  saerok
//
//  Created by HanSeung on 1/28/26.
//

import Foundation

extension CollectionView {
    @Observable
    final class ViewModel {
        // MARK: State
        private(set) var loadingState: LoadState<[Local.CollectionSummary]> = .notRequested
        private(set) var hasUnread: Bool = false
        let birdQuote: String = BirdQuote.random()
        
        // MARK: Dependencies
        private let appState: Store<AppState>
        private let collectionInteractor: CollectionInteractor
        private let userInteractor: UserInteractor
        
        var isGuestMode: Bool { appState[\.authStatus] == .guest }
        
        init(appState: Store<AppState>, collectionInteractor: CollectionInteractor, userInteractor: UserInteractor) {
            self.appState = appState
            self.collectionInteractor = collectionInteractor
            self.userInteractor = userInteractor
        }
        
        func loadPosts() async {
            if !isGuestMode, case .notRequested = loadingState {
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
    }
}
