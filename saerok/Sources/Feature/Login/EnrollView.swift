//
//  EnrollView.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//


import SwiftUI
import SwiftData

struct EnrollView: View {
    @Environment(\.injected) private var injected: DIContainer
    @Binding var user: User
    let onEnrollmentComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            navigationBar
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                Rectangle().fill(.clear)
                    .frame(height: 40)
                EnrollFirstFormView(user: $user, onEnrollmentComplete: onEnrollmentComplete)
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
        }
    }
    
    // MARK: - Subviews
    private var navigationBar: some View {
        NavigationBar(leading: {
            Button(action: handleBackButton) {
                Image.SRIconSet.chevronLeft
                    .frame(.defaultIconSize)
            }
        })
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("회원가입")
                .font(.SRFontSet.headline1)
            Text("닉네임만 입력하면 회원가입이 끝나요!")
                .font(.SRFontSet.body2)
                .foregroundStyle(.secondary)
        }
    }
    
    private func handleBackButton() {
        injected.appState[\.authStatus] = .notDetermined
    }
}

// MARK: - Constants

extension EnrollView {
    enum Constants {
        static let imageSize: CGFloat = 100
        static let imageCornerRadius: CGFloat = 10
        static let formHeight: CGFloat = 44
        static let maxNoteLength: Int = 100
        static let deleteButtonOffset: CGFloat = imageSize / 2
        static let stepCircleSize: CGFloat = 38
    }
}
