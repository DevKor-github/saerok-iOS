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
    @State private var showSplash = true
    
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    private var authStatusUpdate: AnyPublisher<AppState.AuthStatus, Never> {
        injected.appState.updates(for: \.authStatus)
    }
    
    var body: some View {
        ZStack {
            content
            if !networkMonitor.isConnected {
                networkAlertView
            }
        }
        .ignoresSafeArea()
        .animation(.spring(), value: networkMonitor.isConnected)
        .onReceive(authStatusUpdate) { authStatus = $0 }
    }
}

private extension RootSelectorView {
    var content: some View {
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

    var splashView: some View {
        SplashView(showSplash: $showSplash)
    }

    var networkAlertView: some View {
        NetworkAlertView()
    }
}

private struct SplashView: View {
    @Binding var showSplash: Bool
    var body: some View {
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
}

private struct NetworkAlertView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .transition(.opacity)
                .zIndex(1)
            CustomPopup<BorderedButtonStyle, PrimaryButtonStyle, ConfirmButtonStyle>(
                title: "네트워크 연결이 원활하지 않아요",
                message: "인터넷 연결이 불안정하여\n데이터를 불러올 수 없어요.",
                leading: nil,
                trailing: nil,
                center: .init(
                    title: "확인",
                    action: {},
                    style: .confirm
                )
            )
            .zIndex(10)
            .transition(.scale)
        }
    }
}
