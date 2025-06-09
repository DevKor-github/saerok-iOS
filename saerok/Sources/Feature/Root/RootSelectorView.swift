//
//  RootSelectorView.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


import SwiftUI
import Combine

struct RootSelectorView: View {
    @Environment(\.injected) private var injected

    @State private var authStatus: AppState.AuthStatus = .notDetermined
    @State private var user = User()
    @State private var showSplash = false

    @StateObject private var networkMonitor = NetworkMonitor.shared

    private var authStatusUpdate: AnyPublisher<AppState.AuthStatus, Never> {
        injected.appState.updates(for: \.authStatus)
    }

    var body: some View {
        ZStack {
            contentView
            if !networkMonitor.isConnected {
                networkAlertView
            }
        }
        .ignoresSafeArea()
        .animation(.spring(), value: networkMonitor.isConnected)
        .onReceive(authStatusUpdate) { authStatus = $0 }
    }

    // MARK: - Content View
    private var contentView: some View {
        ZStack {
            switch authStatus {
            case .notDetermined:
                LoginView($user, authStatus: $authStatus)

            case .guest:
                ContentView()
                
            case .signedIn(let isRegistered):
                if isRegistered {
                    ContentView()
                } else {
                    LoginView($user, authStatus: $authStatus)
                }
            }

            splashView
                .onAppear {
                    Task {
                        injected.appState[\.authStatus] = await TokenManager.shared.tryAutoLogin()
                    }
                }
        }
    }

    // MARK: - Splash View
    
    @ViewBuilder
    private var splashView: some View {
        if showSplash {
            LottieView(animationName: "splash") {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showSplash = false
                }
            }
            .background(Color.srWhite)
            .ignoresSafeArea()
        }
    }

    // MARK: - Network Alert View
    private var networkAlertView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .transition(.opacity)
                .zIndex(1)

            CustomPopup<BorderedButtonStyle, PrimaryButtonStyle, PrimaryButtonStyle>(
                title: "네트워크 연결이 원활하지 않아요",
                message: "인터넷 연결이 불안정하여\n데이터를 불러올 수 없어요.",
                leading: nil,
                trailing: nil,
                center: .init(
                    title: "확인",
                    action: {},
                    style: .primary
                )
            )
            .zIndex(10)
            .transition(.scale)
        }
    }
}
