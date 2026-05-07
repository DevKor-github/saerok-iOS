//
//  CommunityCommentSection.swift
//  saerok
//
//  Created by Codex on 3/13/26.
//

import SwiftUI

struct CommunityCommentSection: View {
    let comments: [Local.CollectionComment]
    let postUserId: Int
    let isMyPost: Bool
    let onUserTap: (Int) -> Void
    let onReply: (Local.CollectionComment) -> Void
    let onDelete: (Int) async -> Void
    let onReport: (Int) -> Void
    let onBlock: (Int) -> Void

    init(
        comments: [Local.CollectionComment],
        postUserId: Int,
        isMyPost: Bool,
        onUserTap: @escaping (Int) -> Void = { _ in },
        onReply: @escaping (Local.CollectionComment) -> Void = { _ in },
        onDelete: @escaping (Int) async -> Void = { _ in },
        onReport: @escaping (Int) -> Void = { _ in },
        onBlock: @escaping (Int) -> Void = { _ in }
    ) {
        self.comments = comments
        self.postUserId = postUserId
        self.isMyPost = isMyPost
        self.onUserTap = onUserTap
        self.onReply = onReply
        self.onDelete = onDelete
        self.onReport = onReport
        self.onBlock = onBlock
    }

    var body: some View {
        VStack(spacing: 20) {
            header
            if comments.isEmpty {
                emptyView
            } else {
                VStack(spacing: 7) {
                    ForEach(comments) { item in
                        commentThread(for: item)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.srLightGray)
    }

    private var header: some View {
        HStack(spacing: 5) {
            Text("댓글")
            Text("\(comments.count)")
                .foregroundStyle(.splash)
            Spacer()
        }
        .font(.SRFontSet.body4_3)
        .padding(.top, 17)
        .padding(.horizontal, 25)
    }

    private var emptyView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 5) {
                Text("아직 댓글이 없어요!")
                    .font(.SRFontSet.subtitle1_2)
                Text("댓글을 남겨보세요.")
                    .font(.SRFontSet.body2)
                    .foregroundStyle(.secondary)
            }
            Image(.logoBack)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.srWhite)
                .frame(width: 116, height: 128)
        }
        .padding(.top, 78)
        .frame(maxWidth: .infinity)
    }

    private func commentThread(for item: Local.CollectionComment) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            parentCommentView(item)
            repliesView(item)
        }
    }

    private func parentCommentView(_ item: Local.CollectionComment) -> some View {
        CollectionCommentCell(
            collectionUserId: postUserId,
            isMyCollection: isMyPost,
            isReply: false,
            isSelected: false,
            item: item,
            onTap: { onUserTap(item.user.id) },
            onReply: { onReply(item) },
            onDelete: onDelete,
            onReport: { onReport(item.id) },
            onBlock: { onBlock(item.user.id) }
        )
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func repliesView(_ item: Local.CollectionComment) -> some View {
        if let replies = item.replies, !replies.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(replies) { reply in
                    CollectionCommentCell(
                        collectionUserId: postUserId,
                        isMyCollection: isMyPost,
                        isReply: true,
                        isSelected: false,
                        item: reply,
                        onTap: { onUserTap(reply.user.id) },
                        onReply: {},
                        onDelete: onDelete,
                        onReport: { onReport(reply.id) },
                        onBlock: { onBlock(item.user.id) }
                    )
                }
            }
        }
    }
}
