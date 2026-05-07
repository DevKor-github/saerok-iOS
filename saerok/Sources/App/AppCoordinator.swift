//
//  AppCoordinator.swift
//  saerok
//
//  Created by HanSeung on 1/12/26.
//

import Combine
import Foundation
import SwiftUI

protocol AppRoute: Hashable {}

@MainActor
final class AppCoordinator: ObservableObject {
    private let container: DIContainer
    @Published var path = NavigationPath()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Resettable lazy ViewModels
    private var _fieldGuideViewModel: FieldGuideView.ViewModel?
    var fieldGuideViewModel: FieldGuideView.ViewModel {
        if _fieldGuideViewModel == nil { _fieldGuideViewModel = makeFieldGuideViewModel() }
        return _fieldGuideViewModel!
    }

    private var _collectionViewModel: CollectionView.ViewModel?
    var collectionViewModel: CollectionView.ViewModel {
        if _collectionViewModel == nil { _collectionViewModel = makeCollectionViewModel() }
        return _collectionViewModel!
    }

    private var _communityViewModel: CommunityView.ViewModel?
    var communityViewModel: CommunityView.ViewModel {
        if _communityViewModel == nil { _communityViewModel = makeCommunityViewModel() }
        return _communityViewModel!
    }

    private var _mapViewModel: MapView.ViewModel?
    var mapViewModel: MapView.ViewModel {
        if _mapViewModel == nil { _mapViewModel = makeMapViewModel() }
        return _mapViewModel!
    }

    private var _myPageViewModel: MyPageView.ViewModel?
    var myPageViewModel: MyPageView.ViewModel {
        if _myPageViewModel == nil { _myPageViewModel = makeMyPageViewModel() }
        return _myPageViewModel!
    }

    init(container: DIContainer, navigationPath: NavigationPath = NavigationPath()) {
        self.container = container
        self.path = navigationPath

        container.appState
            .updates(for: \.authStatus)
            .filter { $0 == .notDetermined }
            .sink { [weak self] _ in self?.reset() }
            .store(in: &cancellables)
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

    // 로그아웃/세션 만료 시 모든 탭 ViewModel과 네비게이션 스택을 초기화
    @MainActor
    func reset() {
        _fieldGuideViewModel = nil
        _collectionViewModel = nil
        _communityViewModel = nil
        _mapViewModel = nil
        _myPageViewModel = nil
        path = .init()
        container.appState[\.currentUser] = nil
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
    
    func makeCommunityPostDetailViewModel(postId: Int) -> CommunityPostDetailView.ViewModel {
        .init(
            postId: postId,
            interactor: container.interactors.community,
            appState: container.appState
        )
    }

    func makeFreeBoardListViewModel() -> FreeBoardListView.ViewModel {
        .init(
            interactor: container.interactors.community,
            appState: container.appState
        )
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
            appState: container.appState,
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
