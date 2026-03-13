//
//  CommunityPostUserSection.swift
//  saerok
//
//  Created by Codex on 3/13/26.
//

import SwiftUI

struct CommunityPostUserSection: View {
    let user: DTO.User
    let createdAt: String
    let commentCount: Int
    let showsCommentCount: Bool

    init(
        user: DTO.User,
        createdAt: String,
        commentCount: Int,
        showsCommentCount: Bool = true
    ) {
        self.user = user
        self.createdAt = createdAt
        self.commentCount = commentCount
        self.showsCommentCount = showsCommentCount
    }

    var body: some View {
        HStack(spacing: 5) {
            ReactiveAsyncImage(
                url: user.profileImageUrl,
                scale: .small,
                size: .init(width: 25, height: 25),
                downsampling: true
            )
            .srAvatarStyle()

            Text(user.nickname ?? "")
                .font(.SRFontSet.body3_2)

            Text("･")
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)
                .padding(.horizontal, 2)

            Text(createdAt)
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)

            Spacer()

            if showsCommentCount, commentCount > 0 {
                HStack(spacing: 3) {
                    Image.SRIconSet.commentFilled
                        .frame(.defaultIconSize, tintColor: .srLightGray)
                    Text("\(commentCount)")
                        .font(.SRFontSet.caption1_2)
                        .foregroundStyle(.srGray)
                }
            }
        }
    }
}
