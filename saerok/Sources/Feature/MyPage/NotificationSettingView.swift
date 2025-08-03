//
//  AccountView 2.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


//
//  AccountView.swift
//  saerok
//
//  Created by HanSeung on 5/29/25.
//


import SwiftData
import SwiftUI
import KakaoSDKUser

struct AccountView: View {
    @Environment(\.injected) private var injected
    @Environment(\.modelContext) private var modelContext
    
    @Binding var path: NavigationPath
    
    @ObservedObject var userManager = UserManager.shared
    private var user: User? { userManager.user }
    
    @State var showPopup: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            navigationBar
            
            Group {
                userInfoSection
                
                logoutRow
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
            
            Spacer()
        }
        .regainSwipeBack()
        .customPopup(isPresented: $showPopup) { alertView }
    }
    
    @ViewBuilder
    private var userInfoSection: some View {
        if let user = user {
            VStack(spacing: 28) {
                HStack {
                    Text("연결된 소셜로그인 계정")
                    Spacer()
                    Text(user.email)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("가입일자")
                    Spacer()
                    Text(user.joinedDate.toFullString)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.SRFontSet.body2)
        }
    }
    
    private var logoutRow: some View {
        Button {
            showPopup = true

        } label: {
            HStack(spacing: 8) {
                Image.SRIconSet.logout
                    .frame(.custom(width: 19, height: 20))
                    .foregroundStyle(.black)
                    .padding(2)
                Text("로그아웃")
                    .font(.SRFontSet.body2)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 15)
            .background(Color.srLightGray)
            .cornerRadius(.infinity)
        }
        .buttonStyle(.plain)
    }
    
    var navigationBar: some View {
        NavigationBar(
            center: {
                Text("내 계정 관리")
                    .font(.SRFontSet.subtitle2)
            }, leading: {
                Button {
                    path.removeLast()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
            })
    }
    
    var alertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "정말 로그아웃 하시겠어요?",
            message: "",
            leading: .init(
                title: "취소",
                action: { showPopup = false },
                style: .bordered
            ),
            trailing: .init(
                title: "로그아웃",
                action: {
                    showPopup = false
                    logout()
                },
                style: .confirm
            ),
            center: nil
        )
    }
    
    func logout() {        
        Task { @MainActor in
            TokenManager.shared.clearTokens()
            userManager.deleteUser()
            injected.appState[\.authStatus] = .notDetermined
        }
    }
}

