//
//  CollectionCommentCell.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//

import SwiftUI

struct CollectionCommentCell: View {
    let item: Local.CollectionComment
    let onDelete: (Int) -> Void
    let onReport: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(.defaultProfile)
                .resizable()
                .frame(width: 25, height: 25)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .inset(by: 1)
                        .stroke(Color.lightGray, lineWidth: 2)
                )

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    Text(item.nickname)
                        .font(.SRFontSet.body3_2)

                    Text(item.createdAt.korString)
                        .font(.SRFontSet.caption3)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Menu {
                        if item.isMine {
                            Button {
                                onDelete(item.id)
                            } label: {
                                Label("삭제하기", systemImage: "trash")
                            }
                            .disabled(!item.isMine)
                        }
                        
                        Button {
                            onReport()
                        } label: {
                            Label("신고하기", systemImage: "light.beacon.max")
                        }
                    } label: {
                        Image.SRIconSet.option.frame(.defaultIconSize)
                    }
                }
                .frame(height: 20)

                Text(item.content.allowLineBreaking())
                    .font(.SRFontSet.caption1_2)
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(Color.srWhite)
        .cornerRadius(20)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
    }
}
