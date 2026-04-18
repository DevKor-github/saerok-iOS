//
//  CollectionCommentCell.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//

import SwiftUI

struct CollectionCommentCell: View {
    //사용자 차단
    @AppStorage("blockable") var isBlockable: Bool = false
    
    let collectionUserId: Int
    let isMyCollection: Bool
    let isReply: Bool
    let isSelected: Bool
    let item: Local.CollectionComment
    
    let onTap: () -> Void
    let onReply: () -> Void
    let onDelete: (Int) async -> Void
    let onReport: () -> Void
    let onBlock: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            if isReply { Color.clear.frame(width: 14) }
            ReactiveAsyncImage(
                url: item.user.profileImageUrl,
                scale: .medium,
                size: .init(width: 25, height: 25),
                downsampling: true
            )
            .frame(width: 25, height: 25)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .inset(by: 0.8)
                    .stroke(.srLightGray, lineWidth: 2)
            )
            .onTapGesture(perform: onTap) 

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top, spacing: 10) {
                    HStack(spacing: 5) {
                        Text(item.user.nickname)
                            .font(.SRFontSet.body3_2)
                            .onTapGesture(perform: onTap)
                        if item.user.id == collectionUserId {
                            writerTag
                        }
                    }
                    Spacer()
                    if item.isInteractive {
                        replyButton
                        menuButton
                    }
                }
                .frame(height: 22)
                
                Text(item.content.allowLineBreaking())
                    .font(.SRFontSet.caption1_2)
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)
                Text(item.createdAt.timeAgoText)
                    .font(.SRFontSet.caption3)
                    .foregroundStyle(.secondary)
            }
            
            
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(isReply ? Color.clear : (isSelected ? selectedColor : Color.srWhite))
        .cornerRadius(20)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
    }
    
    private let selectedColor: Color = {
        .init(red: 0.92, green: 0.92, blue: 0.92)
    }()
    
    @ViewBuilder
    private var replyButton: some View {
        if !isReply {
            Text("답글달기")
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)
                .onTapGesture(perform: onReply)
        }
    }
    
    private var menuButton: some View {
        Menu {
            if item.isMine || isMyCollection {
                Button {
                    Task {
                        await onDelete(item.id)
                    }
                } label: {
                    Label("삭제하기", systemImage: "trash")
                }
            }
            
            if !item.isMine {
                Button(action: onReport) {
                    Label("신고하기", systemImage: "light.beacon.max")
                }
                //사용자 차단
                if isBlockable {
                    Button(action: onBlock) {
                        Label("사용자 차단하기", systemImage: "person.fill.xmark")
                    }
                }
            }
        } label: {
            Image.SRIconSet.option
                .frame(.defaultIconSize, tintColor: .srGray)
        }
    }
    
    private let writerTag: some View = {
        Text("글쓴이")
            .font(.SRFontSet.caption3_2)
            .padding(.horizontal, 3)
            .padding(.vertical, 1)
            .foregroundStyle(.srWhite)
            .background(Color.splash)
            .cornerRadius(5)
    }()
}
