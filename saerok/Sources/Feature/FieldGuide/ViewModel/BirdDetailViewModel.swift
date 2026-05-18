//
//  BirdDetailViewModel.swift
//  saerok
//
//  Created by HanSeung on 2/3/26.
//

import Foundation

extension BirdDetailView {
    @Observable
    final class ViewModel {
        var birdID: Int?
        var bird: Local.Bird?
        
        // MARK: Dependencies
        private let appStore: AppStore
        private let interactor: FieldGuideInteractor
        var isGuest: Bool { appStore[\.authStatus] == .guest }
        
        init(
            birdID: Int? = nil,
            bird: Local.Bird? = nil,
            appStore: AppStore,
            interactor: FieldGuideInteractor
        ) {
            self.birdID = birdID
            self.bird = bird
            self.appStore = appStore
            self.interactor = interactor
        }
        
        func toggleBookmark(_ id: Int) async {
            guard let bird = bird else { return }
            
            do {
                bird.isBookmarked = try await interactor.toggleBookmark(birdID: id)
            } catch { }
        }
        
        func loadBirdIfNeeded() {
            guard bird == nil,
                  let birdID = birdID
            else { return }
            
            Task { @MainActor in
                if let foundBird = try? await interactor.loadBirdDetails(birdID: birdID) {
                    self.bird = foundBird
                }
            }
        }

        func changeStatusToLogout() {
            appStore.send(.requireAuthentication)
        }
    }
}
