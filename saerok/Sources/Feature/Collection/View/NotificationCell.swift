//
//  NotificationCell.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


import SwiftUI

struct NotificationCell: View {
    let item: Local.Notification
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            actorImage
                .srStyled(.avatar)
                .padding(.leading, 9)
                .padding(.trailing, 6)

            payloadContent
            relatedImage
        }
        .padding(10)
        .frame(minHeight: 78)
        .frame(maxHeight: item.type == .system ? 100 : 78)
        .background(Color.srWhite)
        .cornerRadius(20)
        .overlay(overlayStroke)
        .onTapGesture(perform: onTap)
    }
    
    @ViewBuilder
    private var notificationText: some View {
        switch item.payload {
        case .saerok(let payload):
            switch item.type {
            case .like:
                Text(payload.actorNickname).font(.SRFontSet.body2_3)
                + Text("님이 나의 새록을 좋아해요.").font(.SRFontSet.body4)
            case .comment:
                Text(payload.actorNickname).font(.SRFontSet.body2_3)
                + Text("님이 나의 새록에 댓글을 남겼어요. ").font(.SRFontSet.body4)
                + Text("“\(payload.comment ?? "")”").font(.SRFontSet.body4)
            case .replied:
                Text(payload.actorNickname).font(.SRFontSet.body2_3)
                + Text("님이 새록에 답글을 남겼어요. ").font(.SRFontSet.body4)
                + Text("“\(payload.comment ?? "")”").font(.SRFontSet.body4)
            case .birdIdSuggestion:
                Text("두근두근! 새로운 의견이 공유됐어요. 확인해볼까요?").font(.SRFontSet.body4)
            case .system:
                Text("")
            }
        case .announcement(let payload):
            Text(payload.body).font(.SRFontSet.body4)
                .lineLimit(2)
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
        case .announcement:
            Image(.default)
                .resizable()
                .frame(width: 25, height: 25)
        }
    }
    
    private var payloadContent: some View {
        VStack(alignment: .leading, spacing: 3) {
            if case .announcement = item.payload {
                noticeTag
            }
            
            notificationText
                .font(.SRFontSet.body4)
                .foregroundStyle(item.isRead ? .srGray : .black)
            
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
    
    private let noticeTag: some View = {
        Text("공지사항")
            .font(.SRFontSet.caption3_2)
            .padding(.horizontal, 3)
            .padding(.vertical, 1)
            .foregroundStyle(.srWhite)
            .background(.pointtext)
            .cornerRadius(5)
    }()
    
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
