//
//  NotificationCell.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


import SwiftUI

struct NotificationCell: View {
    let item: Local.Notification
    @State private var isExpanded: Bool = false
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            actorImage
                .padding(.leading, 9)
                .padding(.trailing, 6)

            payloadContent

            if item.type == .adminMessage {
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.srGray)
                }
                .buttonStyle(.borderless)
                .padding(.top, 12)
                .padding(.trailing, 12)
            } else {
                Color.clear.frame(width: 9)
                relatedImage
            }
        }
        .padding(10)
        .frame(minHeight: 78)
        .frame(maxHeight: item.type == .adminMessage && !isExpanded ? 78 : .infinity)
        .clipped()
        .background(item.type == .adminMessage ? Color.srLightGray : Color.srWhite)
        .cornerRadius(20)
        .overlay(overlayStroke)
        .animation(.easeOut(duration: 0.25), value: isExpanded)
        .simultaneousGesture(TapGesture().onEnded { _ in onTap() })
    }

    private var maxCellHeight: CGFloat {
        switch item.type {
        case .system, .adminMessage: return .infinity
        default: return 78
        }
    }

    @ViewBuilder
    private var notificationText: some View {
        switch item.payload {
        case .saerok(let payload):
            switch item.type {
            case .like:
                Text(payload.actorNickname).font(.SRFontSet.body2_3)
                + Text("님이 나의 새록을 좋아해요.".allowLineBreaking()).font(.SRFontSet.body4_2)
            case .comment:
                Text(payload.actorNickname).font(.SRFontSet.body2_3)
                + Text("님이 나의 새록에 댓글을 남겼어요. ".allowLineBreaking()).font(.SRFontSet.body4_2)
                + Text("“\(payload.comment ?? "")“".allowLineBreaking()).font(.SRFontSet.body4_2)
            case .replied:
                Text(payload.actorNickname).font(.SRFontSet.body2_3)
                + Text("님이 나의 새록에 답글을 남겼어요. ".allowLineBreaking()).font(.SRFontSet.body4_2)
                + Text("“\(payload.comment ?? "")“".allowLineBreaking()).font(.SRFontSet.body4_2)
            case .birdIdSuggestion:
                Text("두근두근! 새로운 의견이 공유됐어요. 확인해볼까요?".allowLineBreaking()).font(.SRFontSet.body4_2)
            case .system, .adminMessage, .freeBoardComment, .freeBoardReply:
                Text("")
            }
        case .announcement(let payload):
            Text("\(payload.title ?? "") ").font(.SRFontSet.body2_3)
            + Text(payload.body.allowLineBreaking()).font(.SRFontSet.body4_2)
        case .freeBoard(let payload):
            switch item.type {
            case .freeBoardComment:
                Text(payload.actorNickname).font(.SRFontSet.body2_3)
                + Text("님이 나의 글에 댓글을 남겼어요. ".allowLineBreaking()).font(.SRFontSet.body4_2)
                + Text("“\(payload.comment)“".allowLineBreaking()).font(.SRFontSet.body4_2)
            case .freeBoardReply:
                Text(payload.actorNickname).font(.SRFontSet.body2_3)
                + Text("님이 나의 글에 답글을 남겼어요. ".allowLineBreaking()).font(.SRFontSet.body4_2)
                + Text("“\(payload.comment)“".allowLineBreaking()).font(.SRFontSet.body4_2)
            default:
                Text("")
            }
        }
    }

    @ViewBuilder
    private var actorImage: some View {
        switch item.payload {
        case .saerok(let payload):
            ReactiveAsyncImage(
                url: payload.actorImageUrl,
                scale: .small,
                size: .init(width: 25, height: 25),
                downsampling: true
            )
            .srStyled(.avatar)
            .overlay(alignment: .bottomTrailing) {
                if item.type == .like {
                    likeIconOverlay
                }
            }
        case .freeBoard(let payload):
            ReactiveAsyncImage(
                url: payload.actorImageUrl,
                scale: .small,
                size: .init(width: 25, height: 25),
                downsampling: true
            )
            .srStyled(.avatar)
        case .announcement:
            Image(.default)
                .resizable()
                .frame(width: 25, height: 25)
                .srStyled(.avatar)
        }
    }

    private var likeIconOverlay: some View {
        Image.SRIconSet.heartFilled
            .frame(.custom(width: 9, height: 9), tintColor: .white)
            .padding(4)
            .background(Circle().fill(item.isRead ? Color.lightRed : Color.iconRed))
            .offset(x: 4, y: 4.5)
    }

    private var payloadContent: some View {
        VStack(alignment: .leading, spacing: 3) {
            if case .announcement = item.payload {
                announcementTag
            }

            notificationText
                .font(.SRFontSet.body4)
                .foregroundStyle(item.isRead ? .srGray : .black)
                .lineLimit(nil)

            Text(item.createdAt.timeAgoText)
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var relatedImage: some View {
        if case .saerok(let payload) = item.payload {
            ReactiveAsyncImage(
                url: payload.collectionImageUrl ?? "",
                scale: .small,
                size: .init(width: 60, height: 60),
                downsampling: true
            )
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: 60, maxHeight: 60)
            .clipped()
            .cornerRadius(12)
        } else {
            Spacer()
        }
    }

    private var announcementTag: some View {
        let label = item.type == .adminMessage ? "새록 운영팀" : "공지사항"
        let color: Color = item.type == .adminMessage ? .srGray : .pointtext

        return Text(label)
            .font(.SRFontSet.caption3_2)
            .padding(.horizontal, 3)
            .padding(.vertical, 1)
            .foregroundStyle(.srWhite)
            .background(item.isRead ? .whiteGray : color)
            .cornerRadius(5)
    }

    private var overlayStroke: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 0.4)
                .stroke(Color.srLightGray, lineWidth: 1)

            Circle()
                .fill(item.isRead ? .clear : Color.splash)
                .frame(width: 5, height: 5)
                .offset(x: 9, y: 19)
        }
    }
}
