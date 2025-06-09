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
    }
    
    @Environment(\.injected) var injected
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Binding var path: NavigationPath
    
    var body: some View {
        content
            .navigationDestination(for: MyPageView.Route.self) { route in
                switch route {
                case .account:
                    AccountView(path: $path)
                }
            }
    }
}

private extension MyPageView {
    @ViewBuilder
    var content: some View {
        VStack(spacing: 20) {
            if let user = users.first, let provider = user.provider {
                Text(user.nickname)
                    .font(.SRFontSet.body0)
                Text("새록과 함께한 지 145일")
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.secondary)
                
                Button(role: .destructive) {
                    if provider == .kakao {
                        unlinkKakaoAndDeleteUser(user: user)
                    } else {
                        deleteAppleUserLocally(user: user)
                    }
                } label: {
                    Text("연결 끊기(탈퇴)")
                        .foregroundStyle(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            } else {
                Text("로그인 정보가 없습니다.")
            }
            
            VStack(spacing: 30) {
                settingItem(title: "내 계정 관리", .my) { path.append(Route.account) }
                settingItem(title: "의견 보내기", .insta) {}
                settingItem(title: "새록 소식 및 이용 가이드", .insta) {}
                settingItem(title: "개인정보처리방침", .insta) {}
                settingItem(title: "앱 버전", .insta) {}
            }
            
            Spacer()
        }
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {
                injected.appState[\.authStatus] = .notDetermined
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    func settingItem(title: String, _ icon: Image.SRIconSet, onTap: @escaping () -> Void) -> some View {
        HStack {
            icon
                .frame(.defaultIconSizeLarge)
            Text(title)
                .font(.SRFontSet.body2)
            Spacer()
            Image.SRIconSet.chevronRight
                .frame(.defaultIconSizeSmall)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    func unlinkKakaoAndDeleteUser(user: User) {
        UserApi.shared.unlink { error in
            if let error = error {
                alertMessage = "카카오 연결 끊기에 실패했습니다.\n\(error.localizedDescription)"
                showAlert = true
            } else {
                Task { @MainActor in
                    modelContext.delete(user)
                    alertMessage = "카카오 연결이 성공적으로 해제되었습니다."
                    showAlert = true
                }
            }
        }
    }
    
    func deleteAppleUserLocally(user: User) {
        Task { @MainActor in
            modelContext.delete(user)
            alertMessage = "애플 계정 연결이 해제되었습니다."
            showAlert = true
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path){
        MyPageView(path: $path)
    }
}
