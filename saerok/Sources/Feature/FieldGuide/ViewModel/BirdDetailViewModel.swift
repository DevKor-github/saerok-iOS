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
        private let appState: Store<AppState>
        private let interactor: FieldGuideInteractor
        var isGuest: Bool { appState[\.authStatus] == .guest }
        
        init(
            birdID: Int? = nil,
            bird: Local.Bird? = nil,
            appState: Store<AppState>,
            interactor: FieldGuideInteractor
        ) {
            self.birdID = birdID
            self.bird = bird
            self.appState = appState
            self.interactor = interactor
        }
        
        func toggleBookmark(_ id: Int) async {
            self.bird?.isBookmarked = ((try? await interactor.toggleBookmark(birdID: id)) != nil)
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

        func addSaerok(for bird: Local.Bird) {
            appState.bulkUpdate {
                $0.routing.contentView.tabSelection = .collection
                $0.routing.collectionView.addCollection = true
                $0.routing.addCollectionItemView.selectedBird = bird
            }
        }
        
        func changeStatusToLogout() {
            appState[\.authStatus] = .notDetermined
        }
    }
}
