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
    @StateObject private var versionChecker = AppVersionChecker()

    private var authStatusUpdate: AnyPublisher<AppState.AuthStatus, Never> {
        injected.appState.updates(for: \.authStatus)
    }
    
    var body: some View {
        ZStack {
            content
            if !networkMonitor.isConnected {
                NetworkAlertView()
            }
        }
        .animation(.spring(), value: networkMonitor.isConnected)
        .onReceive(authStatusUpdate) { authStatus = $0 }
        .onChange(of: scenePhase) { before, after in
            ATTrackingManager.requestTrackingAuthorization { _ in }
            if before == .background && after == .inactive {
                Task { @MainActor in
                   injected.appState[\.authStatus] = try await TokenManager.shared.tryAutoLogin()
                }
            }
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
                            injected.appState[\.authStatus] = try await TokenManager.shared.tryAutoLogin()
                        } catch {
                            injected.appState[\.authStatus] = .notDetermined
                        }
                        showSplash = false
                    }
                }
            } else {
                switch authStatus {
                case .notDetermined:
                    LoginView(authStatus: $authStatus)
                case .guest:
                    ContentView()
                case .signedIn(let isRegistered):
                    if isRegistered {
                        ContentView()
                    } else {
                        LoginView(authStatus: $authStatus)
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
