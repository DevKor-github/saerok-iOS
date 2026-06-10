//
//  CommunityPostUserSection.swift
//  saerok
//
//  Created by HanSeung on 5/5/26.
//

import SwiftUI

struct FreeBoardPostUserSection: View {
    let profileImageUrl: String?
    let nickname: String
    let createdAt: Date
    let commentCount: Int
    let showsCommentCount: Bool
    let onUserTap: (() -> Void)?

    init(
        profileImageUrl: String?,
        nickname: String,
        createdAt: Date,
        commentCount: Int,
        showsCommentCount: Bool = true,
        onUserTap: (() -> Void)? = nil
    ) {
        self.profileImageUrl = profileImageUrl
        self.nickname = nickname
        self.createdAt = createdAt
        self.commentCount = commentCount
        self.showsCommentCount = showsCommentCount
        self.onUserTap = onUserTap
    }

    var body: some View {
        HStack(spacing: 7) {
            HStack(spacing: 7) {
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
            .contentShape(Rectangle())
            .onTapGesture { onUserTap?() }
            .allowsHitTesting(onUserTap != nil)

            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 2, height: 2)
                .background(.srGray)
                .cornerRadius(1)

            Text(createdAt.relativeString)
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)

            Spacer()

            if showsCommentCount, commentCount > 0 {
                HStack(spacing: 3) {
                    Image.SRIconSet.commentFilled
                        .frame(.default, tintColor: .srLightGray)
                    Text("\(commentCount)")
                        .font(.SRFontSet.caption1_2)
                        .foregroundStyle(.srGray)
                }
            }
        }
    }
}

private extension Date {
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
