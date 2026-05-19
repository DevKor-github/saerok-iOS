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
    
    @State private var authStatus: AppState.AuthStatus = .notDetermined
    @State private var showSplash = true
    
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var versionChecker = AppVersionChecker()

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
        .onReceive(authStatusUpdate) { newStatus in
            authStatus = newStatus
            if case .notDetermined = newStatus {
                Task { try? await injected.interactors.user.deleteUser() }
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
