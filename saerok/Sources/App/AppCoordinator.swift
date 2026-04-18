//
//  AppCoordinator.swift
//  saerok
//
//  Created by HanSeung on 1/12/26.
//

import Foundation
import SwiftUI

protocol AppRoute: Hashable {}

@MainActor
final class AppCoordinator: ObservableObject {
    private let container: DIContainer
    @Published var path = NavigationPath()
    
    lazy var fieldGuideViewModel = makeFieldGuideViewModel()
    lazy var collectionViewModel = makeCollectionViewModel()
    lazy var communityViewModel = makeCommunityViewModel()
    lazy var mapViewModel = makeMapViewModel()
    lazy var myPageViewModel = makeMyPageViewModel()
    
    init(container: DIContainer, navigationPath: NavigationPath = NavigationPath()) {
        self.container = container
        self.path = navigationPath
    }
    
    func push(_ route: any AppRoute) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func clear() {
        path = .init()
    }
}

// MARK: - ViewModel Factory
extension AppCoordinator {
    func makeCollectionDetailViewModel(
        id: Int,
        entrySource: EntrySource = .unknown,
        screen: Screen = .unknown
    ) -> CollectionDetailView.ViewModel {
        .init(
            collectionID: id,
            entrySource: entrySource,
            screen: screen,
            appState: container.appState,
            collectionInteractor: container.interactors.collection,
            fieldGuideInteractor: container.interactors.fieldGuide,
            userInteractor: container.interactors.user
        )
    }
    
    func makeNotificationViewModel() -> NotificationView.ViewModel {
        .init(interactor: container.interactors.user)
    }
    
    func makeUserSummaryViewModel(_ id: Int) -> UserSummaryView.ViewModel {
        .init(
            userID: id,
            interactor: container.interactors.user
        )
    }
    
    func makeBirdDetailViewModel(birdID: Int? = nil, bird: Local.Bird? = nil) -> BirdDetailView.ViewModel {
        .init(
            birdID: birdID,
            bird: bird,
            appState: container.appState,
            interactor: container.interactors.fieldGuide
        )
    }
    
    func makeCommunityViewModel() -> CommunityView.ViewModel {
        .init(
            appState: container.appState,
            interactor: container.interactors.community
        )
    }
    
    func makeCommunityDetailViewModel(for type: CommunityType) -> CommunityDetailView.ViewModel {
        .init(
            type: type,
            interactor: container.interactors.community
        )
    }
    
    func makeCommunityPostDetailViewModel(
        post: DTO.Post,
        comments: [Local.CollectionComment] = []
    ) -> CommunityPostDetailView.ViewModel {
        .init(post: post, comments: comments)
    }
    
    func makeCollectionViewModel() -> CollectionView.ViewModel {
        .init(
            appState: container.appState,
            collectionInteractor: container.interactors.collection,
            userInteractor: container.interactors.user
        )
    }
    
    func makeFieldGuideViewModel() -> FieldGuideView.ViewModel {
        .init(
            appState: container.appState,
            interactor: container.interactors.fieldGuide
        )
    }
    
    func makeFieldGuideSearchViewModel() -> FieldGuideSearchView.ViewModel {
        .init(
            appState: container.appState,
            interactor: container.interactors.fieldGuide
        )
    }
    
    func makeMyPageViewModel() -> MyPageView.ViewModel {
        .init(
            appState: container.appState,
            interactor: container.interactors.user
        )
    }
    
    func makeAccountViewModel() -> AccountView.ViewModel {
        .init(
            appState: container.appState,
            interactor: container.interactors.user
        )
    }
    
    func makeBoardViewModel() -> BoardView.ViewModel {
        .init(interactor: container.interactors.user)
    }
    
    func makeCollectionFormViewModel(mode: CollectionFormMode, bird: Local.Bird? = nil) -> CollectionFormView.ViewModel {
        .init(
            appState: container.appState,
            fieldguideInteractor: container.interactors.fieldGuide,
            collectionInteractor: container.interactors.collection,
            mode: mode,
            bird: bird
        )
    }
    
    func makeMapViewModel() -> MapView.ViewModel {
        .init(
            mapInteractor: container.interactors.map,
            appState: container.appState
        )
    }
    
    func makeEditProfileViewModel() -> EditProfileView.ViewModel {
        .init(
            interactor: container.interactors.user
        )
    }
    
    func makeCollectionLikerSheetViewModel(_ id: Int) -> CollectionLikerSheet.ViewModel {
        .init(
            collectionID: id,
            interactor: container.interactors.collection
        )
    }
}
