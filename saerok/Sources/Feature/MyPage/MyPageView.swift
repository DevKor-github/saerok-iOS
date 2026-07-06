//
//  MyPageView.swift
//  saerok
//
//  Created by HanSeung on 5/20/25.
//

import Combine
import SwiftData
import SwiftUI
import KakaoSDKUser

enum MyPageRoute: AppRoute {
    case account
    case editProfile
    case notification
    case board
    case boardDetail(id: Int)
}

extension MyPageView {
    struct Routing: Equatable {
        var boardDetailId: Int?
    }
    
    @Observable
    final class ViewModel {
        enum Output: Equatable {
            case navigateToBoardDetail(_ id: Int)
        }
        
        private(set) var user: AppState.UserProfile? = nil
        var output: Output?

        // MARK: Dependencies
        private let appStore: AppStore
        private let interactor: UserInteractor
        private(set) var isGuest: Bool

        private let cancelBag: CancelBag

        init(appStore: AppStore, interactor: UserInteractor) {
            self.appStore = appStore
            self.interactor = interactor
            self.cancelBag = .init()
            self.user = appStore[\.currentUser]
            self.isGuest = appStore[\.authStatus] == .guest
            
            cancelBag.collect {
                appStore
                    .updates(for: \.pendingDeepLink)
                    .compactMap { link -> Int? in
                        guard case .boardDetail(let id) = link else { return nil }
                        return id
                    }
                    .weakSink(on: self) { viewModel, id in
                        viewModel.output = .navigateToBoardDetail(id)
                        viewModel.appStore.send(.clearPendingDeepLink)
                    }

                appStore
                    .updates(for: \.currentUser)
                    .weakSink(on: self) { viewModel, profile in
                        viewModel.user = profile
                    }

                appStore
                    .updates(for: \.authStatus)
                    .map { $0 == .guest }
                    .removeDuplicates()
                    .weakSink(on: self) { viewModel, isGuest in
                        viewModel.isGuest = isGuest
                    }
            }
        }
        
        func changeStatusToLogout() {
            appStore.send(.requireAuthentication)
        }
        
        func syncUser() {
            Task {
                guard !isGuest, user == nil else { return }
                guard let me = try? await interactor.getUser() else { return }
                await MainActor.run {
                    appStore.send(.syncCurrentUser(.init(me)))
                }
            }
        }
        
        func resetOutput() {
            output = nil
        }
    }
}

struct MyPageView: View {
    typealias Route = MyPageRoute
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @Bindable private var viewModel: ViewModel
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        return "\(version)"
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .account:
                    AccountView(viewModel: coordinator.factory.makeAccountViewModel())
                case .notification:
                    NotificationSettingView()
                case .editProfile:
                    EditProfileView(viewModel: coordinator.factory.makeEditProfileViewModel())
                case .board:
                    BoardView(viewModel: coordinator.factory.makeBoardViewModel())
                case .boardDetail(id: let id):
                    BoardDetailView(id: id, viewModel: coordinator.factory.makeBoardViewModel())
                }
            }
            .onChange(of: viewModel.output, initial: true) { _, output in
                guard let output = output else { return }
                
                switch output {
                case .navigateToBoardDetail(let id):
                    coordinator.push(Route.board)
                    coordinator.push(Route.boardDetail(id: id))
                }
                viewModel.resetOutput()
            }
            .task(id: viewModel.isGuest ? "guest" : "user") {
                viewModel.syncUser()
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
            .padding(.horizontal, SRSpacing.screenHorizontal)
        }
        .ignoresSafeArea(.all)
        .regainSwipeBack()
    }
    
    @ViewBuilder
    var userSection: some View {
        if let _ = viewModel.user, !viewModel.isGuest {
            nicknameView
        } else {
            toLoginView
        }
    }
    
    var settingsSection: some View {
        VStack(spacing: 16) {
            SettingItemView(
                title: "내 계정 관리",
                icon: .my,
                onTap: { coordinator.push(Route.account) },
                isDisabled: viewModel.isGuest
            )
            .disabled(viewModel.user == nil)
            
            SettingItemView(title: "공지사항", icon: .megaphone) { coordinator.push(Route.board) }
            SettingItemView(title: "알림 설정", icon: .bell) { coordinator.push(Route.notification) }
                .disabled(viewModel.user == nil)
            
            SettingItemView(title: "새록 소식 및 이용 가이드", icon: .board) { openURL(.instagram) }
            SettingItemView(title: "개인정보 처리 방침", icon: .locker) { openURL(.개인정보) }
            SettingItemView(title: "의견 보내기", icon: .plane) { openURL(.feedback) }
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
                    .frame(.large)
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
            .srStyled(.chip(background: .splash))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            viewModel.changeStatusToLogout()
        }
    }
    
    private var nicknameView: some View {
        UserInfoView(
            type: .my,
            user: .init(
                id: 0,
                nickname: viewModel.user?.nickname ?? "",
                profileImageUrl: viewModel.user?.imageURL ?? ""
            ),
            joinedDate: viewModel.user?.joinedDate ?? .now,
            onTap: { coordinator.push(Route.editProfile) }
        )
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

struct UserInfoView: View {
    enum ViewType {
        case my
        case other
    }
    
    let type: ViewType
    let user: Local.UserSummary
    let joinedDate: Date
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: type == .my ? .top : .center, spacing: 8) {
            ReactiveAsyncImage(
                url: user.profileImageUrl,
                scale: .small,
                size: .init(width: 50, height: 50),
                downsampling: true
            )
            .aspectRatio(contentMode: .fill)
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .inset(by: 1)
                    .stroke(.srLightGray, lineWidth: 2)
            )
            
            VStack(alignment: .leading, spacing: type == .my ? 8 : 0) {
                nameView
                daySinceView
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            if type == .my {
                Button(action: onTap) {
                    Image.SRIconSet.edit
                        .frame(.large)
                }
                .srStyled(.iconButton)
            }
        }
    }
    
    @ViewBuilder
    private var nameView: some View {
        switch type {
        case .my:
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
        case .other:
            HStack(spacing: 0) {
                Text(user.nickname)
                    .font(.SRFontSet.headline2)
                    .foregroundStyle(.splash)
                Text("님의 새록")
                    .font(.SRFontSet.subtitle2)
            }
        }
    }
    
    private var daySinceView: some View {
        Text("새록과 함께한 지 +\(joinedDate.daysSince)일")
            .font(.SRFontSet.caption1)
            .foregroundStyle(.secondary)
    }
}
