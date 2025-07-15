//
//  CollectionEmptyStateView.swift
//  saerok
//
//  Created by HanSeung on 6/6/25.
//


//
//  CollectionEmptyStateView.swift
//  saerok
//
//  Created by HanSeung on 6/6/25.
//

import SwiftUI

struct CollectionEmptyStateView: View {
    @Environment(\.injected) private var injected

    let isGuest: Bool
    let addButtonTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            headerSection
            contentSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Header

    private var headerSection: some View {
        CollectionHeaderView(collectionCount: 0, addButtonTapped: addButtonTapped)
    }

    // MARK: - Content

    private var contentSection: some View {
        ZStack(alignment: .center) {
            if isGuest {
                loginButton
            } else {
                Image(.logoBack)
                    .resizable()
                    .frame(width: 116, height: 128)
                    .padding(.bottom, 20)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(isGuest ? "로그인이 필요한 서비스예요" : "아직은 발견한 새가 없어요!")
                    .font(.SRFontSet.subtitle1_2)

                Text(isGuest
                     ? "로그인하고 탐조 기록을 시작해보세요!"
                     : "오른쪽 깃털 버튼을 눌러 탐조 기록을 시작해보세요.")
                    .font(.SRFontSet.body2)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(SRDesignConstant.defaultPadding)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color.srWhite)
    }

    // MARK: - Login Button

    private var loginButton: some View {
        Button {
            injected.appState[\.authStatus] = .notDetermined
        } label: {
            HStack(spacing: 8) {
                    Image.SRIconSet.login
                        .frame(.custom(width: 19, height: 20), tintColor: .white)
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
        .padding(.bottom, 30)
        .buttonStyle(.plain)
    }
}
