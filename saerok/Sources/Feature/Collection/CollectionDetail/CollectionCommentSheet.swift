//
//  CollectionCommentSheet.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//


import SwiftUI

struct CollectionCommentSheet: View {
    let nickname: String
    let comments: [Local.CollectionComment]
    let onDelete: (Int) -> Void
    let onReport: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            header

            if comments.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack(spacing: 7) {
                        ForEach(comments) { item in
                            CollectionCommentCell(
                                item: item,
                                onDelete: onDelete,
                                onReport: onReport
                            )
                        }

                        Color.clear
                            .frame(height: UIScreen.main.bounds.height * 0.5)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("댓글")
            Text("\(comments.count)")
                .foregroundStyle(.splash)
            Spacer()
            Button(action: onDismiss) {
                Image.SRIconSet.delete.frame(.defaultIconSizeSmall, tintColor: .srGray)
            }
        }
        .font(.SRFontSet.subtitle2)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
    }

    private var emptyView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 5) {
                Text("아직 댓글이 없어요!")
                    .font(.SRFontSet.subtitle1_2)
                Text("댓글을 남겨보세요.")
                    .font(.SRFontSet.body2)
                    .foregroundStyle(.secondary)
            }
            Image(.logoBack)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.srWhite)
                .frame(width: 116, height: 128)
        }
        .padding(.top, 78)
    }
}
