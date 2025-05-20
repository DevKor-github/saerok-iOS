//
//  saerokApp.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUI
import SwiftData

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
    }
}


struct RootSelectorView: View {
    @Query var users: [User]
    //    @State var isLoggedIn: Bool = true
    @State var isLoggedIn: Bool = false
    
    @State private var showSplash = false
    
    @ViewBuilder
    var body: some View {
        ZStack {
            Group {
                if !users.isEmpty && isLoggedIn {
                    //                    if true {
                    
                    ContentView()
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 1.5), value: isLoggedIn)
                } else {
                    LoginView($isLoggedIn)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: isLoggedIn)
                }
            }
            
            if showSplash {
                LottieView(animationName: "splash", completion: {
                    withAnimation(.easeInOut(duration: 2)) {
                        showSplash = false
                    }
                })
                .background(Color.srWhite)
                .ignoresSafeArea()
            }
        }
    }
}
