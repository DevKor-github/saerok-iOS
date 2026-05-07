//
//  PostCell.swift
//  saerok
//
//  Created by HanSeung on 3/11/26.
//

import SwiftUI

struct PostCell: View {
    let post: Local.FreeBoardPost

    var body: some View {
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
    }

    var user: some View {
        FreeBoardPostUserSection(
            profileImageUrl: post.thumbnailProfileImageUrl,
            nickname: post.nickname,
            createdAt: post.createdAt,
            commentCount: post.commentCount,
            showsCommentCount: true
        )
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
