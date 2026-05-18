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
            appStore: container.appStore,
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
            appStore: container.appStore,
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
            appStore: container.appStore,
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
            appStore: container.appStore,
            interactor: container.interactors.fieldGuide
        )
    }

    func makeFieldGuideSearchViewModel() -> FieldGuideSearchView.ViewModel {
        .init(
            appStore: container.appStore,
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
            appStore: container.appStore,
            interactor: container.interactors.fieldGuide
        )
    }
}

// MARK: - Community
extension ViewModelFactory {
    func makeCommunityViewModel() -> CommunityView.ViewModel {
        .init(
            appStore: container.appStore,
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
            appStore: container.appStore
        )
    }

    func makeFreeBoardListViewModel() -> FreeBoardListView.ViewModel {
        .init(
            interactor: container.interactors.community,
            appStore: container.appStore
        )
    }
}

// MARK: - Map
extension ViewModelFactory {
    func makeMapViewModel() -> MapView.ViewModel {
        .init(
            mapInteractor: container.interactors.map,
            appStore: container.appStore
        )
    }
}

// MARK: - MyPage
extension ViewModelFactory {
    func makeMyPageViewModel() -> MyPageView.ViewModel {
        .init(
            appStore: container.appStore,
            interactor: container.interactors.user
        )
    }

    func makeAccountViewModel() -> AccountView.ViewModel {
        .init(
            appStore: container.appStore,
            interactor: container.interactors.user
        )
    }

    func makeEditProfileViewModel() -> EditProfileView.ViewModel {
        .init(
            appStore: container.appStore,
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
