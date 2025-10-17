//
//  AppEnvironment.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//

import SwiftData
import Foundation

@MainActor
struct AppEnvironment {
    let modelContainer: ModelContainer
    let diContainer: DIContainer
    
    /// 앱 실행 시 필요한 모든 의존성들을 초기화하여 `AppEnvironment`를 생성합니다.
    /// - Returns: 초기화 된 `AppEnvironment` 인스턴스
    static func bootstrap() -> AppEnvironment {
        resetStoreOnceIfNeeded()

        let appState = Store<AppState>(AppState())
        let modelContainer = configuredModelContainer()
        let networkService = SRNetworkServiceImpl()
        let mainRepository = configuredRepositories(modelContainer: modelContainer, networkService: networkService)
        let interactors = configuredInteractors(repositories: mainRepository)
        let diContainer = DIContainer(appState: appState, interactors: interactors, networkService: networkService)
        UserManager.shared.configure(with: ModelContext(modelContainer))

        return AppEnvironment(modelContainer: modelContainer, diContainer: diContainer)
    }
    
    static func resetStoreOnceIfNeeded() {
        let defaults = UserDefaults.standard
        let flagKey = "didResetSwiftDataV2"

        guard defaults.bool(forKey: flagKey) == false else { return }

        let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
        try? FileManager.default.removeItem(at: storeURL)

        defaults.set(true, forKey: flagKey)
    }
}

// MARK: - 의존성 구성 메서드

private extension AppEnvironment {
    /// 앱에서 사용할 `ModelContainer`를 설정합니다.
    /// 설정 중 오류가 발생하면 미리보기 전용 컨테이너로 대체됩니다.
    static func configuredModelContainer() -> ModelContainer {
        do {
            return try ModelContainer.appModelContainer()
        } catch {
            return ModelContainer.previewable
        }
    }
    
    /// 앱의 주요 저장소(Repository)들을 생성하고 반환합니다.
    /// - Parameter modelContainer: 로컬 데이터를 저장하는 데 사용할 `ModelContainer`
    static func configuredRepositories(
        modelContainer: ModelContainer,
        networkService: SRNetworkService
    ) -> DIContainer.Repositories {
        let mainRepository: MainRepository = .init(modelContainer: modelContainer)
        return .init(birds: mainRepository, collections: mainRepository, community: mainRepository, user: mainRepository)
    }
    
    /// 저장소를 기반으로 앱에서 사용할 인터랙터들을 생성합니다.
    /// - Parameter repositories: 인터랙터에 주입할 저장소
    static func configuredInteractors(repositories: DIContainer.Repositories)-> DIContainer.Interactors {
        return .init(
            fieldGuide: FieldGuideInteractorImpl(repository: repositories.birds),
            collection: CollectionInteractorImpl(repository: repositories.collections),
            community: CommunityInteractorImpl(repository: repositories.community),
            user: UserInteractorImpl(repository: repositories.user)
        )
    }
}
