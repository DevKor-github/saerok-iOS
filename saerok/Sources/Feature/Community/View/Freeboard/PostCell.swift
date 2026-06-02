//
//  PostCell.swift
//  saerok
//
//  Created by HanSeung on 3/11/26.
//

import SwiftUI

struct PostCell: View {
    let post: Local.FreeBoardPost
    let onTap: (() -> Void)?

    init(
        post: Local.FreeBoardPost,
        onTap: (() -> Void)? = nil
    ) {
        self.post = post
        self.onTap = onTap
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 3) {
                user
                content
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 13)
            .overlay(alignment: .bottom) {
                divider
                    .offset(y: 1)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }

            if post.commentCount > 0 {
                HStack(spacing: 3) {
                    Image.SRIconSet.commentFilled
                        .frame(.default, tintColor: .srLightGray)
                    Text("\(post.commentCount)")
                        .font(.SRFontSet.caption1_2)
                        .foregroundStyle(.srGray)
                }
                .padding(.trailing, 24)
                .padding(.top, 13)
            }
        }
    }

    var user: some View {
        FreeBoardPostUserSection(
            profileImageUrl: post.thumbnailProfileImageUrl,
            nickname: post.nickname,
            createdAt: post.createdAt,
            commentCount: post.commentCount,
            showsCommentCount: false
        )
        .padding(.trailing, post.commentCount > 0 ? 32 : 0)
    }

    var content: some View {
        Text(post.content.allowLineBreaking())
            .font(.SRFontSet.body4_2)
            .lineSpacing(10)
            .lineLimit(4)
            .padding(.leading, 30)
    }

    private let divider: some View = {
        Rectangle()
            .fill(Color.srLightGray)
            .frame(height: 1)
    }()
}
