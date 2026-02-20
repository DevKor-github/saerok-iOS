//
//  FieldGuideViewModel.swift
//  saerok
//
//  Created by HanSeung on 12/9/25.
//

import Foundation
import Combine

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
        enum Output: Equatable {
            case showBirdDetail(Local.Bird)
            case scrollToTop(UUID)
        }
        
        // MARK: State
        var fieldGuide: [Local.Bird] = []
        var fieldGuideState: LoadState<Void> = .notRequested
        var filterKey: BirdFilter = .init()
        var output: Output?
        
        // MARK: Dependencies
        private let appState: Store<AppState>
        private var interactor: FieldGuideInteractor
        private var isGuest: Bool { appState[\.authStatus] == .guest }
        
        private let cancelBag: CancelBag
        
        init(appState: Store<AppState>, interactor: FieldGuideInteractor) {
            self.appState = appState
            self.interactor = interactor
            self.cancelBag = .init()
            binding()
        }
        
        private func binding() {
            cancelBag.collect {
                appState
                    .updates(for: \.routing.fieldGuideView.birdName)
                    .sink { [weak self] name in
                        guard let self,
                              let name,
                              let bird = self.fieldGuide.first(where: { $0.name == name })
                        else { return }
                        
                        self.output = .showBirdDetail(bird)
                    }
                
                appState
                    .updates(for: \.routing.fieldGuideView.scrollToTop)
                    .compactMap { $0 }
                    .weakSink(on: self) { viewModel, _ in
                        viewModel.output = .scrollToTop(UUID())
                    }
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
