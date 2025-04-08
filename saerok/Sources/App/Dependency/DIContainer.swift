//
//  DIContainer.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import SwiftUI
import SwiftData

struct DIContainer {
    let appState: Store<AppState>
    let interactors: Interactors

    init(appState: Store<AppState> = .init(AppState()), interactors: Interactors) {
        self.appState = appState
        self.interactors = interactors
    }

    init(appState: AppState, interactors: Interactors) {
        self.init(appState: Store<AppState>(appState), interactors: interactors)
    }
}

extension DIContainer {
    struct Repositories {
        let birds: BirdsRepository
    }
    
    struct Interactors {
        let fieldGuide: FieldGuideInteractor

        static var stub: Self {
            .init(fieldGuide: MockFieldGuideInteractorImpl())
        }
    }
}

// MARK: - 의존성 주입 관련

extension EnvironmentValues {
    /// DIContainer를 SwiftUI의 @Environment에 등록
    @Entry var injected: DIContainer = DIContainer(appState: AppState(), interactors: .stub)
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
