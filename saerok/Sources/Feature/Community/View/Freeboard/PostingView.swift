//
//  PostingView.swift
//  saerok
//
//  Created by HanSeung on 3/10/26.
//

import SwiftUI

struct PostingView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    let nickname: String
    let profileImageUrl: String?

    @State private var contents: String
    @State private var isUploading: Bool = false
    @State private var showFloatingMenu: Bool = false
    @Binding var isPresented: Bool
    @FocusState var isFocused: Bool

    let buttonTitle: String
    let onPost: (String) async -> Void

    init(
        nickname: String,
        profileImageUrl: String?,
        isPresented: Binding<Bool>,
        initialContent: String = "",
        buttonTitle: String = "게시하기",
        onPost: @escaping (String) async -> Void
    ) {
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self._isPresented = isPresented
        self._contents = State(wrappedValue: initialContent)
        self.buttonTitle = buttonTitle
        self.onPost = onPost
    }

    var body: some View {
        content
            .regainSwipeBack()
            .modifier(FloatingMenuModifier(postAction: {}, saerokAction: {}, bottomOffset: 24, showMenu: $showFloatingMenu, isHidden: $isPresented))
    }

    @ViewBuilder
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationBar
            Divider()
                .background(Color.srLightGray)
                .frame(height: 1)
            Group {
                userView
                    .padding(.top, 13)
                TextField("자유로운 글을 작성해보세요!", text: $contents)
                    .font(.SRFontSet.body4_2)
                    .padding(.leading, 30)
                    .padding(.top, 3)
                    .focused($isFocused)
                    .onAppear {
                        isFocused.toggle()
                    }
                Spacer()
                Button(action: {
                    isUploading = true
                    Task {
                        await onPost(contents)
                        isPresented = false
                    }
                }) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text(buttonTitle)
                    }
                }
                .srStyled(.primaryButton)
                .disabled(isUploading || contents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .safeAreaPadding(.bottom, 17)
            }
            .padding(.horizontal, 24)
        }
        .presentationDetents([.large])
        .presentationCornerRadius(20)
    }
}

private extension PostingView {
    var navigationBar: some View {
        NavigationBar(
            leading: {
                Text("자유게시판")
                    .font(.SRFontSet.subtitle2)
            },
            trailing: {
                Button {
                    isPresented.toggle()
                } label: {
                    Image.SRIconSet.x
                        .frame(.small, tintColor: .srGray)
                }
            }
        )
    }

    var userView: some View {
        HStack(spacing: 5) {
            ReactiveAsyncImage(
                url: profileImageUrl ?? "",
                scale: .small,
                size: .init(width: 25, height: 25),
                downsampling: true
            )
            .srAvatarStyle()
            Text(nickname)
                .font(.SRFontSet.body3_2)
        }
    }
}
