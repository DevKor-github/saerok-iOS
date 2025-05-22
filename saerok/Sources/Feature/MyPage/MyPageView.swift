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
    @Environment(\.injected) var injected
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("마이페이지")
                .font(.SRFontSet.headline1)
            
            if let user = users.first, let provider = user.provider {
                Text(user.nickname)
                Text("\(user.provider?.rawValue ?? "무")로 로그인")
                Text(user.email)
                Text(user.id)
                
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
            
            Spacer()
        }
        .padding()
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {
                injected.appState[\.authStatus] = .notDetermined
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func unlinkKakaoAndDeleteUser(user: User) {
        UserApi.shared.unlink { error in
            if let error = error {
                alertMessage = "카카오 연결 끊기에 실패했습니다.\n\(error.localizedDescription)"
                showAlert = true
            } else {
                Task { @MainActor in
                    modelContext.delete(user)
                    try? KeyChain.delete(key: .kakaoLogin)
                    alertMessage = "카카오 연결이 성공적으로 해제되었습니다."
                    showAlert = true
                }
            }
        }
    }
    
    private func deleteAppleUserLocally(user: User) {
        Task { @MainActor in
            modelContext.delete(user)
            try? KeyChain.delete(key: .appleLogin)
            alertMessage = "애플 계정 연결이 해제되었습니다."
            showAlert = true
        }
    }
}

#Preview {
    MyPageView()
}
