//
//  saerokApp.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUI
import SwiftData
import Combine

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@main
struct saerokApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppID)
    }
    
    var body: some Scene {
        WindowGroup {
            appDelegate.rootView
        }
    }
}

extension AppEnvironment {
    var rootView: some View {
        RootSelectorView()
            .modelContainer(modelContainer)
            .inject(diContainer)
            .onOpenURL { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    let _ = AuthController.handleOpenUrl(url: url)
                }
            }
            .onAppear {
                try? KeyChain.delete(key: .appleLogin)
                try? KeyChain.delete(key: .kakaoLogin)
            }
    }
}

struct RootSelectorView: View {
    @Environment(\.injected) private var injected
    @State private var authStatus: AppState.AuthStatus = .notDetermined
    @State private var user: User = .init()
    @State private var showSplash = false
    var authStatusUpdate: AnyPublisher<AppState.AuthStatus, Never> {
        injected.appState.updates(for: \.authStatus)
    }
    
    var body: some View {
        content
            .onReceive(authStatusUpdate) { authStatus = $0 }
            .onAppear {
                checkAutoLogin()
            }
    }
    
    private var content: some View {
        ZStack {
            switch authStatus {
            case .notDetermined:
                LoginView($user)
            case .guest:
                ContentView()
            case .signedIn(let isRegistered):
                if isRegistered {
                    ContentView()
                } else {
                    LoginView($user)
                }
            }
            
            splashView
        }
    }
    
    @ViewBuilder
    private var splashView: some View {
        if showSplash {
            LottieView(animationName: "splash", completion: {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showSplash = false
                }
            })
            .background(Color.srWhite)
            .ignoresSafeArea()
        }
    }
    
    private func checkAutoLogin() {
        if let _ = try? KeyChain.read(key: .appleLogin) {
            injected.appState[\.authStatus] = .signedIn(isRegistered: true)
        } else if let _ = try? KeyChain.read(key: .kakaoLogin) {
            injected.appState[\.authStatus] = .signedIn(isRegistered: true)
        } else {
            injected.appState[\.authStatus] = .notDetermined
        }
    }
    
//    private func checkAutoLogin() {
//        if let token = try? KeyChain.read(key: .appleLogin) {
//            Task {
//                let isRegistered = await verifyTokenWithServer(provider: "apple", token: token)
//                injected.appState[\.authStatus] = .signedIn(isRegistered: isRegistered)
//            }
//        } else if let token = try? KeyChain.read(key: .kakaoLogin) {
//            Task {
//                let isRegistered = await verifyTokenWithServer(provider: "kakao", token: token)
//                injected.appState[\.authStatus] = .signedIn(isRegistered: isRegistered)
//            }
//        } else {
//            injected.appState[\.authStatus] = .guest
//        }
//    }
}
