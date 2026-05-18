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
        private let appStore: AppStore
        private var interactor: FieldGuideInteractor
        private(set) var isGuest: Bool
        
        private let cancelBag: CancelBag
        
        init(appStore: AppStore, interactor: FieldGuideInteractor) {
            self.appStore = appStore
            self.interactor = interactor
            self.cancelBag = .init()
            self.isGuest = appStore[\.authStatus] == .guest
            binding()
        }
        
        private func binding() {
            cancelBag.collect {
                appStore.events
                    .weakSink(on: self) { viewModel, event in
                        guard case .fieldGuideBirdRequested(let name) = event,
                              !name.isEmpty,
                              let bird = viewModel.fieldGuide.first(where: { $0.name == name })
                        else { return }

                        viewModel.output = .showBirdDetail(bird)
                    }
                
                appStore.events
                    .filter {
                        if case .fieldGuideScrollToTop = $0 { return true }
                        return false
                    }
                    .weakSink(on: self) { viewModel, _ in
                        viewModel.output = .scrollToTop(UUID())
                    }

                appStore
                    .updates(for: \.authStatus)
                    .map { $0 == .guest }
                    .removeDuplicates()
                    .weakSink(on: self) { viewModel, isGuest in
                        viewModel.isGuest = isGuest
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
            
            if !isGuest {
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
            appStore.send(.requireAuthentication)
        }
    }
}
