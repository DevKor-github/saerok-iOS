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
    let onDelete: (() -> Void)?
    let onReport: (() -> Void)?

    init(
        post: Local.FreeBoardPost,
        onTap: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onReport: (() -> Void)? = nil
    ) {
        self.post = post
        self.onTap = onTap
        self.onDelete = onDelete
        self.onReport = onReport
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

            if onDelete != nil || onReport != nil {
                Menu {
                    if post.isMine, let onDelete {
                        Button(role: .destructive, action: onDelete) {
                            Label("삭제하기", systemImage: "trash")
                        }
                    } else if let onReport {
                        Button(action: onReport) {
                            Label("신고하기", systemImage: "light.beacon.max")
                        }
                    }
                } label: {
                    Image.SRIconSet.option
                        .frame(.default, tintColor: .srGray)
                        .padding(.trailing, 24)
                        .padding(.top, 13)
                }
            }
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
        .padding(.trailing, onDelete != nil || onReport != nil ? 32 : 0)
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
