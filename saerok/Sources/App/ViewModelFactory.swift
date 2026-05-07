//
//  ViewModelFactory.swift
//  saerok
//

import Foundation

@MainActor
struct ViewModelFactory {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }
}

// MARK: - Collection
extension ViewModelFactory {
    func makeCollectionViewModel() -> CollectionView.ViewModel {
        .init(
            appState: container.appState,
            collectionInteractor: container.interactors.collection,
            userInteractor: container.interactors.user
        )
    }

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

    func makeCollectionFormViewModel(
        mode: CollectionFormMode,
        bird: Local.Bird? = nil
    ) -> CollectionFormView.ViewModel {
        .init(
            appState: container.appState,
            fieldguideInteractor: container.interactors.fieldGuide,
            collectionInteractor: container.interactors.collection,
            mode: mode,
            bird: bird
        )
    }

    func makeCollectionLikerSheetViewModel(_ id: Int) -> CollectionLikerSheet.ViewModel {
        .init(
            collectionID: id,
            interactor: container.interactors.collection
        )
    }
}

// MARK: - FieldGuide
extension ViewModelFactory {
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

    func makeBirdDetailViewModel(
        birdID: Int? = nil,
        bird: Local.Bird? = nil
    ) -> BirdDetailView.ViewModel {
        .init(
            birdID: birdID,
            bird: bird,
            appState: container.appState,
            interactor: container.interactors.fieldGuide
        )
    }
}

// MARK: - Community
extension ViewModelFactory {
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
}

// MARK: - Map
extension ViewModelFactory {
    func makeMapViewModel() -> MapView.ViewModel {
        .init(
            mapInteractor: container.interactors.map,
            appState: container.appState
        )
    }
}

// MARK: - MyPage
extension ViewModelFactory {
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

    func makeEditProfileViewModel() -> EditProfileView.ViewModel {
        .init(
            appState: container.appState,
            interactor: container.interactors.user
        )
    }

    func makeBoardViewModel() -> BoardView.ViewModel {
        .init(interactor: container.interactors.user)
    }
}

// MARK: - User
extension ViewModelFactory {
    func makeNotificationViewModel() -> NotificationView.ViewModel {
        .init(interactor: container.interactors.user)
    }

    func makeUserSummaryViewModel(_ id: Int) -> UserSummaryView.ViewModel {
        .init(
            userID: id,
            interactor: container.interactors.user
        )
    }
}
