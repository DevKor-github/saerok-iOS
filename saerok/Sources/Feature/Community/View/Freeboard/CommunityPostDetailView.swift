//
//  CommunityPostDetailView.swift
//  saerok
//
//  Created by HanSeung on 3/13/26.
//

import SwiftUI

struct CommunityPostDetailView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.showToast) private var showToast
    @State private var viewModel: ViewModel
    @State private var showDeletePostAlert: Bool = false
    @State private var showEditPostSheet: Bool = false
    @FocusState private var isInputFocused: Bool
    @State private var keyboard: KeyboardObserver = .init()

    private let onUserTap: (Int) -> Void

    init(viewModel: ViewModel, onUserTap: @escaping (Int) -> Void) {
        self.viewModel = viewModel
        self.onUserTap = onUserTap
    }

    var body: some View {
        content
            .task { await viewModel.load() }
            .onChange(of: viewModel.output) { _, new in
                switch new {
                case .postDeleted:
                    coordinator.pop()
                    showToast(.init(type: .success, message: "게시글을 삭제했어요.", placementOffset: -58, transitionOffset: 160, duration: 2.0))
                case .reportSubmitted:
                    showToast(.init(type: .success, message: "게시글을 신고했어요.", placementOffset: -58, transitionOffset: 160, duration: 2.0))
                case .none: break
                }
            }
            .sheet(isPresented: $showEditPostSheet) {
                if let post = viewModel.post {
                    PostingView(
                        nickname: post.nickname,
                        profileImageUrl: post.thumbnailProfileImageUrl,
                        isPresented: $showEditPostSheet,
                        initialContent: post.content,
                        buttonTitle: "수정하기"
                    ) { content in
                        await viewModel.editPost(content: content)
                    }
                }
            }
    }
}

private extension CommunityPostDetailView {
    var content: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                navigationBar
                Divider()
                    .frame(height: 1)
                    .foregroundStyle(.srLightGray)
                scrollContent
            }
            inputBar
        }
        .background(Color.srWhite)
        .regainSwipeBack()
        .srPopup(isPresented: $showDeletePostAlert, config: deletePostPopupConfig)
        .onTapGesture { isInputFocused = false }
        .ignoresSafeArea(edges: .bottom)
    }
    
    var deletePostPopupConfig: PopupConfig {
        .init(
            title: "게시글을 삭제하시겠어요?",
            message: "\(formatText(viewModel.post?.content))게시글이 삭제돼요.",
            buttons: .double(
                .init(title: "취소", style: .confirm) { showDeletePostAlert = false },
                .init(title: "삭제하기", style: .delete) { Task { await viewModel.deletePost() } }
            )
        )
    }
    
    func formatText(_ text: String?) -> String {
        let limit = 10
        guard let text else { return "" }
        
        if text.count <= limit {
            return "'\(text)...'"
        } else {
            let truncated = text.prefix(limit)
            return "'\(truncated)...'"
        }
    }

    var navigationBar: some View {
        NavigationBar(
            center: {
                HStack(spacing: 6) {
                    Image.SRIconSet.post
                        .frame(.default, tintColor: nil)
                        .padding(4)
                        .background(Color.srGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("도란도란")
                        .font(.SRFontSet.subtitle2)
                }
            },
            leading: {
                Button { coordinator.pop() } label: {
                    Image.SRIconSet.chevronLeft.frame(.default)
                }
                .srStyled(.borderedIconButton)
            }
        )
    }

    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                if let post = viewModel.post {
                    postSection(post)
                        .padding(.vertical, 13)
                        .background(Color.srWhite)
                }
                CommunityCommentSection(
                    comments: viewModel.comments,
                    postUserId: viewModel.post?.userId ?? 0,
                    isMyPost: viewModel.isMyPost,
                    onUserTap: onUserTap,
                    onReply: { comment in viewModel.selectedComment = comment },
                    onDelete: { commentId in await viewModel.deleteComment(commentId) }
                )
                .onTapGesture {
                    isInputFocused = false
                    viewModel.selectedComment = nil
                }
                Color.clear.frame(height: 100)
            }
        }
        .background(Color.srLightGray)
    }

    func postSection(_ post: Local.FreeBoardPost) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            FreeBoardPostUserSection(
                profileImageUrl: post.thumbnailProfileImageUrl,
                nickname: post.nickname,
                createdAt: post.createdAt,
                commentCount: post.commentCount,
                showsCommentCount: false,
                onUserTap: { onUserTap(post.userId) }
            )
            .overlay(alignment: .trailing) {
                Menu {
                    if post.isMine {
                        Button(action: {
                            showEditPostSheet = true
                        }) {
                            Label("수정하기", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: {
                            showDeletePostAlert = true
                        }) {
                            Label("삭제하기", systemImage: "trash")
                        }
                    } else {
                        Button(action: {
                            Task { await viewModel.reportPost() }
                        }) {
                            Label("신고하기", systemImage: "light.beacon.max")
                        }
                    }
                } label: {
                    Image.SRIconSet.option
                        .frame(.default, tintColor: .srGray)
                }
            }
            Text(post.content.allowLineBreaking())
                .font(.SRFontSet.body4_2)
                .lineSpacing(10)
        }
        .padding(.horizontal, 24)
    }

    var inputBar: some View {
        CollectionCommentInputBar(
            text: $viewModel.commentText,
            selectedNickname: viewModel.selectedComment?.user.nickname,
            nickname: viewModel.post?.nickname ?? "(알 수 없음)",
            onSubmit: { await viewModel.submitComment() },
            isOnSheet: false,
            isFocused: _isInputFocused,
            keyboard: keyboard,
            isGuest: viewModel.isGuest
        )
    }
}
