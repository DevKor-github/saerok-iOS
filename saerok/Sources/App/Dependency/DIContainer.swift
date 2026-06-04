//
//  DIContainer.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import SwiftData
import SwiftUI

struct DIContainer {
    let appStore: AppStore
    let interactors: Interactors
    let networkService: SRNetworkService

    init(appStore: AppStore = .init(), interactors: Interactors, networkService: SRNetworkService) {
        self.appStore = appStore
        self.interactors = interactors
        self.networkService = networkService
    }

    init(appState: AppState, interactors: Interactors, networkSevice: SRNetworkService) {
        self.init(
            appStore: AppStore(appState),
            interactors: interactors,
            networkService: networkSevice
        )
    }
}

extension DIContainer {
    struct Repositories {
        let birds: BirdsRepository
        let collections: CollectionRepository
        let community: CommunityRepository
        let map: MapRepository
        let user: UserRepository
    }
    
    struct Interactors {
        let fieldGuide: FieldGuideInteractor
        let collection: CollectionInteractor
        let community: CommunityInteractor
        let map: MapInteractor
        let user: UserInteractor
        
        nonisolated(unsafe) static let stub: Interactors = .init(
            fieldGuide: MockFieldGuideInteractorImpl(),
            collection: MockCollectionInteractorImpl(),
            community: MockCommunityInteractorImpl(),
            map: MockMapInteractorImpl(),
            user: MockUserInteractorImpl()
        )
    }
}

// MARK: - 의존성 주입 관련

extension EnvironmentValues {
    /// DIContainer를 SwiftUI의 @Environment에 등록합니다.
    ///
    /// 뷰 계층 어디서든 `@Environment(\.injected)`를 통해 DIContainer에 접근할 수 있게 됩니다.
    @Entry var injected: DIContainer =
        .init(appStore: AppStore(AppState()),
              interactors: .stub,
              networkService: SRNetworkServiceImpl()
        )
}

extension View {
    /// DIContainer와 AppCoordinator를 현재 뷰 계층에 주입합니다.
    ///
    /// coordinator는 반드시 외부에서 생성된 안정적인 인스턴스를 전달해야 합니다.
    /// 호출부에서 매번 새로 생성하면 이전 인스턴스의 weak 참조가 댕글링됩니다.
    func inject(_ container: DIContainer, coordinator: AppCoordinator) -> some View {
        return self
            .environment(\.injected, container)
            .environmentObject(coordinator)
    }
}
