//
//  NotificationCell.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


import SwiftUI

struct NotificationCell: View {
    let item: Local.Notification
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onTap: () -> Void

    @State private var oneLineTextHeight: CGFloat = 0
    @State private var fullTextHeight: CGFloat = 0

    private static let collapsedHeight: CGFloat = 78

    private var isAdmin: Bool { item.type == .adminMessage }

    private var textTargetHeight: CGFloat {
        isExpanded ? fullTextHeight : oneLineTextHeight
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            actorImage
                .padding(.leading, 9)
                .padding(.trailing, 6)

            payloadContent

            if isAdmin {
                Button(action: onToggleExpand) {
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
        .frame(minHeight: Self.collapsedHeight, alignment: .top)
        .srStyled(.card(background: isAdmin ? Color.srLightGray : Color.srWhite, shadow: nil))
        .overlay(overlayStroke)
        .simultaneousGesture(TapGesture().onEnded { _ in onTap() })
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
            .srStyled(.avatar())
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
            .srStyled(.avatar())
        case .announcement:
            Image(.default)
                .resizable()
                .frame(width: 25, height: 25)
                .srStyled(.avatar())
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

            messageText

            Text(item.createdAt.timeAgoText)
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // admin: 타임스탬프는 클립 밖에 두고 텍스트 높이만 AnimatableHeightContainer로 보간
    @ViewBuilder
    private var messageText: some View {
        let styled = notificationText
            .font(.SRFontSet.body4)
            .foregroundStyle(item.isRead && !isAdmin ? .srGray : .black)

        if isAdmin {
            AnimatableHeightContainer(height: textTargetHeight) {
                styled
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(textHeightMeasurers(styled))
        } else {
            styled.lineLimit(nil)
        }
    }

    private func textHeightMeasurers(_ styled: some View) -> some View {
        ZStack(alignment: .topLeading) {
            measurer(styled, lineLimit: 1) { oneLineTextHeight = $0 }
            measurer(styled, lineLimit: nil) { fullTextHeight = $0 }
        }
        .hidden()
    }

    private func measurer(_ content: some View, lineLimit: Int?, onHeight: @escaping (CGFloat) -> Void) -> some View {
        content
            .lineLimit(lineLimit)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GeometryReader { proxy in
                Color.clear
                    .onAppear { onHeight(proxy.size.height) }
                    .onChange(of: proxy.size.height) { _, v in onHeight(v) }
            })
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
        return SRTagBadge(text: label, background: item.isRead && !isAdmin ? .whiteGray : color)
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

// withAnimation 시 SwiftUI가 height를 프레임 단위로 보간해 주변 행도 부드럽게 재배치
private struct AnimatableHeightContainer<Content: View>: View, Animatable {
    var height: CGFloat
    let content: Content

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    init(height: CGFloat, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }

    var body: some View {
        content
            .frame(height: max(height, 0), alignment: .top)
            .clipped()
    }
}
