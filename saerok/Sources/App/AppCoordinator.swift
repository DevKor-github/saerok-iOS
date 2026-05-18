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
        guard let vm = _fieldGuideViewModel else { fatalError("FieldGuideView.ViewModel 생성 실패") }
        return vm
    }

    private var _collectionViewModel: CollectionView.ViewModel?
    var collectionViewModel: CollectionView.ViewModel {
        if _collectionViewModel == nil { _collectionViewModel = factory.makeCollectionViewModel() }
        guard let vm = _collectionViewModel else { fatalError("CollectionView.ViewModel 생성 실패") }
        return vm
    }

    private var _communityViewModel: CommunityView.ViewModel?
    var communityViewModel: CommunityView.ViewModel {
        if _communityViewModel == nil { _communityViewModel = factory.makeCommunityViewModel() }
        guard let vm = _communityViewModel else { fatalError("CommunityView.ViewModel 생성 실패") }
        return vm
    }

    private var _mapViewModel: MapView.ViewModel?
    var mapViewModel: MapView.ViewModel {
        if _mapViewModel == nil { _mapViewModel = factory.makeMapViewModel() }
        guard let vm = _mapViewModel else { fatalError("MapView.ViewModel 생성 실패") }
        return vm
    }

    private var _myPageViewModel: MyPageView.ViewModel?
    var myPageViewModel: MyPageView.ViewModel {
        if _myPageViewModel == nil { _myPageViewModel = factory.makeMyPageViewModel() }
        guard let vm = _myPageViewModel else { fatalError("MyPageView.ViewModel 생성 실패") }
        return vm
    }

    init(container: DIContainer, navigationPath: NavigationPath = NavigationPath()) {
        self.container = container
        self.factory = ViewModelFactory(container: container)
        self.path = navigationPath

        container.appStore
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
    }
}
