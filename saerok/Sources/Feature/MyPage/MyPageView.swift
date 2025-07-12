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
        case editName
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
                case .editName:
                    EditNicknameView(path: $path)
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
            SettingItemView(title: "내 계정 관리", icon: .my, trailing: nil, onTap: {
                path.append(Route.account)
            }, isDisabled: isGuest)
            .disabled(user == nil)
            SettingItemView(title: "새록 소식 및 이용 가이드", icon: .bell, onTap: { openInstagramPage() })
            SettingItemView(title: "개인정보 처리 방침", icon: .locker, onTap: { open개인정보처리방침() })
            SettingItemView(title: "의견 보내기", icon: .board, onTap: { openFeedbackForm() })
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
        VStack(alignment: .leading, spacing: 8) {
            Button {
                path.append(Route.editName)
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text("안녕하세요,")
                        .font(.SRFontSet.subtitle2)
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("\(user.nickname)")
                            .font(.SRFontSet.headline2)
                        Text("님!")
                            .font(.SRFontSet.subtitle2)
                        Image.SRIconSet.edit
                            .frame(.defaultIconSizeLarge, tintColor: .splash)
                    }
                }
            }
            
            Text("새록과 함께한 지 +\(user.joinedDate.daysSince)일")
                .font(.SRFontSet.caption1)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .buttonStyle(.plain)
    }
    
    func openInstagramPage() {
        if let url = URL(string: "https://www.instagram.com/saerok.app/?utm_source=ig_web_button_share_sheet") {
            UIApplication.shared.open(url)
        }
    }
    
    func open개인정보처리방침() {
        if let url = URL(string: "https://shine-guppy-3de.notion.site/2127cea87e0581af9a9acd2f36f28e3b") {
            UIApplication.shared.open(url)
        }
    }
    
    func openFeedbackForm() {
        if let url = URL(string: "https://shine-guppy-3de.notion.site/2127cea87e0581af9a9acd2f36f28e3b") {
            UIApplication.shared.open(url)
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

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path){
        MyPageView(path: $path)
    }
}
