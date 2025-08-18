//
//  DIContainer.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import SwiftData
import SwiftUI

struct DIContainer {
    let appState: Store<AppState>
    let interactors: Interactors
    let networkService: SRNetworkService

    init(appState: Store<AppState> = .init(AppState()), interactors: Interactors, networkService: SRNetworkService) {
        self.appState = appState
        self.interactors = interactors
        self.networkService = networkService
    }

    init(appState: AppState, interactors: Interactors, networkSevice: SRNetworkService) {
        self.init(appState: Store<AppState>(appState), interactors: interactors, networkService: networkSevice)
    }
}

extension DIContainer {
    struct Repositories {
        let birds: BirdsRepository
        let collections: CollectionRepository
        let user: UserRepository
    }
    
    struct Interactors {
        let fieldGuide: FieldGuideInteractor
        let collection: CollectionInteractor
        let user: UserInteractor
        
        nonisolated(unsafe) static let stub: Interactors = .init(
            fieldGuide: MockFieldGuideInteractorImpl(),
            collection: MockCollectionInteractorImpl(),
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
        .init(appState: AppState(),
              interactors: .stub,
              networkSevice: SRNetworkServiceImpl()
        )
}

extension View {
    /// DIContainer를 현재 뷰 계층에 주입합니다.
    ///
    /// 이 메서드는 DIContainer를 SwiftUI의 Environment에 등록하여,
    /// 하위 뷰들이 의존성에 접근할 수 있도록 합니다.
    ///
    /// - Parameter container: 주입할 DIContainer 인스턴스
    /// - Returns: DIContainer가 주입된 새로운 뷰 인스턴스
    func inject(_ container: DIContainer) -> some View {
        return self
            .environment(\.injected, container)
    }
}
