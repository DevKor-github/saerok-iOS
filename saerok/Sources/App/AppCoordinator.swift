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
    let factory: ViewModelFactory
    @Published var path = NavigationPath()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - 탭 루트 ViewModel (로그아웃 시 reset 대상)
    private var _fieldGuideViewModel: FieldGuideView.ViewModel?
    var fieldGuideViewModel: FieldGuideView.ViewModel {
        if _fieldGuideViewModel == nil { _fieldGuideViewModel = factory.makeFieldGuideViewModel() }
        return _fieldGuideViewModel!
    }

    private var _collectionViewModel: CollectionView.ViewModel?
    var collectionViewModel: CollectionView.ViewModel {
        if _collectionViewModel == nil { _collectionViewModel = factory.makeCollectionViewModel() }
        return _collectionViewModel!
    }

    private var _communityViewModel: CommunityView.ViewModel?
    var communityViewModel: CommunityView.ViewModel {
        if _communityViewModel == nil { _communityViewModel = factory.makeCommunityViewModel() }
        return _communityViewModel!
    }

    private var _mapViewModel: MapView.ViewModel?
    var mapViewModel: MapView.ViewModel {
        if _mapViewModel == nil { _mapViewModel = factory.makeMapViewModel() }
        return _mapViewModel!
    }

    private var _myPageViewModel: MyPageView.ViewModel?
    var myPageViewModel: MyPageView.ViewModel {
        if _myPageViewModel == nil { _myPageViewModel = factory.makeMyPageViewModel() }
        return _myPageViewModel!
    }

    init(container: DIContainer, navigationPath: NavigationPath = NavigationPath()) {
        self.container = container
        self.factory = ViewModelFactory(container: container)
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
