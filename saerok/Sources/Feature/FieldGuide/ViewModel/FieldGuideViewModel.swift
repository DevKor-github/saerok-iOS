//
//  FieldGuideViewModel.swift
//  saerok
//
//  Created by HanSeung on 12/9/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Routing
extension FieldGuideView {
    struct Routing: Equatable {
        var birdName: String?
        var scrollToTop: UUID?
    }
}

// MARK: - ViewModel
extension FieldGuideView {
    @Observable
    final class ViewModel {
        // MARK: State
        var fieldGuide: [Local.Bird] = []
        var fieldGuideState: LoadState<Void> = .notRequested
        var filterKey: BirdFilter = .init()
        var routingState = Routing() {
            didSet {
                appState[\.routing.fieldGuideView] = routingState
            }
        }
        
        private let cancelBag: CancelBag

        // MARK: Dependencies
        private let appState: Store<AppState>
        private var interactor: FieldGuideInteractor
        private var isGuest: Bool { appState[\.authStatus] == .guest }

        init(appState: Store<AppState>, interactor: FieldGuideInteractor) {
            self.appState = appState
            self.interactor = interactor
            self.cancelBag = .init()
            
            cancelBag.collect {
                appState
                    .updates(for: \.routing.fieldGuideView)
                    .weakAssign(to: \.routingState, on: self)
            }
        }
 
        func loadFieldGuide() {
            if !fieldGuide.isEmpty {
                fieldGuideState = .success(())
            } else {
                fieldGuideState = .loading
                Task {
                    do {
                        try await interactor.refreshFieldGuide()
                        fieldGuideState = .success(())
                    } catch {
                        fieldGuideState = .failure(error)
                    }
                }
            }
            
            if appState[\.authStatus] != .guest {
                Task {
                    try? await interactor.refreshBookmarks()
                }
            }
        }
        
        func bookmarkTapped() {
            filterKey.isBookmarked.toggle()
        }
        
        func toggleBookmark(bird: Local.Bird) async throws {
            bird.isBookmarked = try await interactor.toggleBookmark(birdID: bird.id)
        }
        
        func navigateToLoginView() {
            appState[\.authStatus] = .notDetermined
        }
    }
}
