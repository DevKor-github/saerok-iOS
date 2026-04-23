//
//  CommunityPostDetailView.swift
//  saerok
//
//  Created by Codex on 3/13/26.
//

import SwiftUI

struct CommunityPostDetailView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var viewModel: ViewModel
    @State private var showToast: Bool = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            Divider()
                .frame(height: 1)
                .foregroundStyle(.srGray)
            content
        }
        .background(Color.srWhite)
        .regainSwipeBack()
        .task {
            try? await Task.sleep(for: .seconds(1))
            showToast.toggle()
        }
    }
}

private extension CommunityPostDetailView {
    var navigationBar: some View {
        NavigationBar(
            center: {
                Text("자유게시판")
                    .font(.SRFontSet.subtitle2)
            },
            leading: {
                Button {
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
                .srStyled(.borderedIconButton)
            }
        )
    }
    
    var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                postSection
                commentSection
                Color.clear.frame(height: 40)
            }
            .padding(.top, 16)
        }
    }
    
    var postSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            CommunityPostUserSection(
                user: viewModel.post.author,
                createdAt: viewModel.post.createdAt,
                commentCount: viewModel.post.commentCount,
                showsCommentCount: false
            )
            
            Text(viewModel.post.content.allowLineBreaking())
                .font(.SRFontSet.body4_2)
                .lineSpacing(10)
        }
        .padding(.horizontal, 24)
    }
    
    var commentSection: some View {
        CommunityCommentSection(
            comments: viewModel.comments,
            postUserId: viewModel.post.author.userId,
            isMyPost: viewModel.isMyPost
        )
    }
}

#if DEBUG
#Preview {
    CommunityPostDetailView(
        viewModel: .init(
            post: CommunityDetailView.mockPosts[0],
            comments: CommunityPostDetailView.ViewModel.mockComments
        )
    )
}
#endif
