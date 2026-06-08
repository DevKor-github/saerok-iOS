//
//  RootSelectorView.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//

import SwiftUI
import Combine
import AppTrackingTransparency

struct RootSelectorView: View {
    @Environment(\.injected) private var injected
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var authStatus: AppState.AuthStatus = .notDetermined
    @State private var showSplash = true

    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var versionChecker = AppVersionChecker()

    /// 스플래시가 뜨는 동안 첫 화면(CommunityView)의 메인 데이터를 미리 받아오는 작업.
    /// `community/main`은 인증이 필요 없어 autoLogin과 병렬로 안전하게 선조회할 수 있다.
    @State private var communityPrefetchTask: Task<Void, Never>?

    private var authStatusUpdate: AnyPublisher<AppState.AuthStatus, Never> {
        injected.appStore.updates(for: \.authStatus)
    }
    
    var body: some View {
        ZStack {
            content
            if !networkMonitor.isConnected {
                NetworkAlertView()
            }
        }
        .animation(.spring(), value: networkMonitor.isConnected)
        .onAppear(perform: startCommunityPrefetchIfNeeded)
        .onReceive(authStatusUpdate) { newStatus in
            authStatus = newStatus
            if case .notDetermined = newStatus {
                Task { try? await injected.interactors.user.deleteUser() }
            }
            // 로그인 콜백은 앱 시작 시점에만 발생하므로, 실행 중 로그인한 계정은
            // 이 시점에 현재 기기의 FCM 토큰을 재등록해야 푸시를 받을 수 있다.
            if case .signedIn(let isRegistered) = newStatus, isRegistered {
                Task { await PushNotificationManager.shared.reRegisterDevice() }
            }
        }
        .onChange(of: scenePhase) { before, after in
            ATTrackingManager.requestTrackingAuthorization { _ in }
            if before == .background && after == .inactive {
                Task { @MainActor in
                    do {
                        let status = try await TokenManager.shared.tryAutoLogin()
                        await applyAuthStatus(status)
                    } catch {
                        injected.appStore.send(.requireAuthentication)
                    }
                }
            }
        }
        .task { await versionChecker.checkVersion() }
        .alert("업데이트 필요", isPresented: $versionChecker.showUpdateAlert) {
            Button("앱스토어로 이동") {
                AppStorePresenter.present(appID: "6744866662")
            }
        } message: {
            Text("새로운 버전이 출시되었습니다.\n최신 버전으로 업데이트해주세요.")
        }
    }
}

private extension RootSelectorView {
    /// 스플래시 노출과 동시에 첫 화면 데이터 선조회를 시작한다. 한 번만 실행된다.
    func startCommunityPrefetchIfNeeded() {
        guard communityPrefetchTask == nil else { return }
        communityPrefetchTask = Task { @MainActor in await coordinator.communityViewModel.loadPosts() }
    }

    func loadCurrentUser() async throws {
        let user = try await injected.interactors.user.getUser()
        injected.appStore.send(.syncCurrentUser(.init(user)))
    }

    func applyAuthStatus(_ status: AppState.AuthStatus) async {
        switch status {
        case .signedIn(let isRegistered):
            if isRegistered {
                do {
                    try await loadCurrentUser()
                    injected.appStore.send(.finishSignIn(isRegistered: isRegistered))
                } catch UserInteractorError.invalidUser {
                    try? await injected.interactors.user.deleteUser()
                    await TokenManager.shared.clearTokens()
                    injected.appStore.send(.requireAuthentication)
                } catch {
                    injected.appStore.send(.restoreSession(status))
                }
            } else {
                try? await injected.interactors.user.deleteUser()
                injected.appStore.send(.restoreSession(status))
            }
        default:
            injected.appStore.send(.restoreSession(status))
        }
    }
}

private extension RootSelectorView {
    var content: some View {
        Group {
            if showSplash {
                SplashView(showSplash: $showSplash) {
                    Task {
                        do {
                            let status = try await TokenManager.shared.tryAutoLogin()
                            await applyAuthStatus(status)
                        } catch {
                            injected.appStore.send(.requireAuthentication)
                        }
                        // 선조회가 아직 끝나지 않았다면 완료를 기다린 뒤 화면을 전환해
                        // CommunityView가 로딩 상태 없이 바로 데이터와 함께 뜨도록 한다.
                        await communityPrefetchTask?.value
                        showSplash = false
                    }
                }
            } else {
                switch authStatus {
                case .notDetermined:
                    LoginView(
                        authStatus: $authStatus,
                        onSignIn: { injected.appStore.send(.finishSignIn(isRegistered: $0)) },
                        onEnterGuestMode: { injected.appStore.send(.enterGuestMode) },
                        onRequireAuth: { injected.appStore.send(.requireAuthentication) }
                    )
                case .guest:
                    ContentView()
                case .signedIn(let isRegistered):
                    if isRegistered {
                        ContentView()
                    } else {
                        LoginView(
                            authStatus: $authStatus,
                            onSignIn: { injected.appStore.send(.finishSignIn(isRegistered: $0)) },
                            onEnterGuestMode: { injected.appStore.send(.enterGuestMode) },
                            onRequireAuth: { injected.appStore.send(.requireAuthentication) }
                        )
                    }
                }
            }
        }
    }
}

private struct SplashView: View {
    @Binding var showSplash: Bool
    let onAppear: () -> Void
    
    var body: some View {
        if showSplash {
            LottieView(animationName: "splash") {
                withAnimation(.easeInOut(duration: 0.8)) {
                    onAppear()
                }
            }
            .background(Color.srWhite)
            .ignoresSafeArea()
        }
    }
}

private struct NetworkAlertView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .transition(.opacity)
                .zIndex(1)
            SRPopup(
                title: networkErrorPopupConfig.title,
                message: networkErrorPopupConfig.message,
                buttons: networkErrorPopupConfig.buttons
            )
            .zIndex(10)
            .transition(.scale)
        }
    }
    
    let networkErrorPopupConfig = PopupConfig(
        title: "네트워크 연결이 원활하지 않아요",
        message: "인터넷 연결이 불안정하여\n데이터를 불러올 수 없어요.",
        buttons: .single(
            .init(
                title: "확인",
                style: .confirm,
                action: {}
            )
        )
    )
}
