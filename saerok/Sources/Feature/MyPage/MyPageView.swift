//
//  MyPageView.swift
//  saerok
//
//  Created by HanSeung on 5/20/25.
//


import SwiftData
import SwiftUI
import KakaoSDKUser

struct MyPageView: View {
    enum Route {
        case account
        case editProfile
        case notification
    }
    
    @Environment(\.injected) var injected
    
    @ObservedObject var userManager = UserManager.shared
    private var user: User? { userManager.user }
    
    @Binding var path: NavigationPath
    @State private var showAlert = false
    @State private var alertMessage = ""
    private var isGuest: Bool { injected.appState[\.authStatus] == .guest }
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        return "\(version)"
    }
    
    var body: some View {
        content
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .account:
                    AccountView(path: $path)
                case .notification:
                    NotificationSettingView(path: $path)
                case .editProfile:
                    EditProfileView(path: $path)
                }
            }
            .onAppear {
                syncUser()
            }
    }
}

private extension MyPageView {
    @ViewBuilder
    var content: some View {
        ZStack(alignment: .topTrailing) {
            Image(.mypageLogo)

            VStack(spacing: 35) {
                Color.clear.frame(height: 80)
                userSection
                settingsSection
                Spacer()
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
        }
        .ignoresSafeArea(.all)
        .regainSwipeBack()
    }
    
    @ViewBuilder
    var userSection: some View {
        if let user = user, !isGuest {
            nicknameView(user)
        } else {
            toLoginView
        }
    }
    
    var settingsSection: some View {
        VStack(spacing: 16) {
            SettingItemView(
                title: "내 계정 관리",
                icon: .my,
                onTap: { path.append(Route.account) },
                isDisabled: isGuest
            )
            .disabled(user == nil)
            
            SettingItemView(title: "알림 설정", icon: .bell, onTap: { path.append(Route.notification) })
            
            SettingItemView(title: "새록 소식 및 이용 가이드", icon: .board, onTap: { openURL(.instagram) })
            
            SettingItemView(title: "개인정보 처리 방침", icon: .locker, onTap: { openURL(.개인정보) })
            
            SettingItemView(title: "의견 보내기", icon: .plane, onTap: { openURL(.feedback) })
            
            SettingItemView(
                title: "버전 정보",
                icon: .info,
                trailing: AnyView(
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                ),
                onTap: {}
            )
            .disabled(true)
        }
    }
    
    var toLoginView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image.SRIconSet.alert
                    .frame(.defaultIconSizeLarge)
                Text("현재 비회원으로 사용 중이에요.\n로그인하시겠어요?")
                    .font(.SRFontSet.body2)
            }
            
            HStack(spacing: 8) {
                Image.SRIconSet.login
                    .frame(.custom(width: 19, height: 20))
                    .padding(2)
                
                Text("로그인 / 회원가입")
                    .font(.SRFontSet.body2)
                    .foregroundStyle(.srWhite)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 15)
            .background(Color.splash)
            .cornerRadius(.infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            injected.appState[\.authStatus] = .notDetermined
        }
    }
    
    func nicknameView(_ user: User) -> some View {
        HStack(alignment: .top, spacing: 8) {
            ReactiveAsyncImage(url: user.imageURL ?? "", scale: .large, quality: 1.0, downsampling: true)
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .inset(by: 1)
                        .stroke(.srLightGray, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("안녕하세요,")
                        .font(.SRFontSet.subtitle2)
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("\(user.nickname)")
                            .font(.SRFontSet.headline2)
                        Text("님!")
                            .font(.SRFontSet.subtitle2)
                    }
                }
                
                Text("새록과 함께한 지 +\(user.joinedDate.daysSince)일")
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button {
                path.append(Route.editProfile)
            } label: {
                Image.SRIconSet.edit
                    .frame(.defaultIconSizeLarge)
            }
            .buttonStyle(.icon)
        }
    }
    
    private func syncUser() {
        Task {
            do {
                let me: DTO.MeResponse = try await injected.networkService.performSRRequest(.me)
                userManager.syncUser(from: me)
            }
        }
    }
}

private extension MyPageView {
    enum SRURL: String {
        case feedback = "https://docs.google.com/forms/d/e/1FAIpQLSeUMFVcG0L1OYU5_fBl8SWHQQOExdonQAU1cLtbyp7Z5Rp_ew/viewform?usp=dialog"
        case instagram = "https://www.instagram.com/saerok.app/?utm_source=ig_web_button_share_sheet"
        case 개인정보 = "https://shine-guppy-3de.notion.site/2127cea87e0581af9a9acd2f36f28e3b"
    }
    
    func openURL(_ type: SRURL) {
        guard let url = URL(string: type.rawValue) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path){
        MyPageView(path: $path)
    }
}
