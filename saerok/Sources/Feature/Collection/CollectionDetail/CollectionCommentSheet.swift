//
//  CollectionCommentSheet.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//


import SwiftUI

struct CollectionCommentSheet: View {
    let collectionId: Int
    let isMyCollection: Bool
    let nickname: String
    let comments: [Local.CollectionComment]
    let onTap: (_ userId: Int) -> Void
    let onDelete: (Int) -> Void
    let onDismiss: () -> Void

    @State var showReportCommentPopup: Bool = false
    @State private var selectedCommentId: Int? = nil

    @Environment(\.injected) private var injected: DIContainer

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
                                isMyCollection: isMyCollection,
                                item: item,
                                onTap: { onTap(item.user.id) },
                                onDelete: onDelete,
                                onReport: {
                                    selectedCommentId = item.id
                                    showReportCommentPopup.toggle()
                                }
                            )
                        }

                        Color.clear
                            .frame(height: UIScreen.main.bounds.height * 0.5)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .customPopup(isPresented: $showReportCommentPopup) {
            commentReportAlertView
        }
    }

    private var header: some View {
        HStack {
            Text("댓글")
            Text("\(comments.count)")
                .foregroundStyle(.splash)
            Spacer()
            Button(action: onDismiss) {
                Image.SRIconSet.delete
                    .frame(.defaultIconSizeSmall, tintColor: .srGray)
                    .padding(.leading, 20)
                    .padding(.vertical, 5)
            }
            .contentShape(Rectangle())
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
    
    var commentReportAlertView: CustomPopup<DeleteButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "이 댓글을 신고하시겠어요?",
            message: "커뮤니티 가이드에 따라\n신고 사유에 해당하는지 검토 후 처리돼요.",
            leading: .init(
                title: "신고하기",
                action: {
                    test()
                    showReportCommentPopup = false
                },
                style: .delete
            ),
            trailing: .init(
                title: "돌아가기",
                action: { showReportCommentPopup = false },
                style: .confirm
            ),
            center: nil
        )
    }
    
    func test() {
        if let id = selectedCommentId {
            Task {
                do {
                    try await injected.interactors.collection.reportComment(
                        collecionId: collectionId,
                        commentId: id
                    )
                    selectedCommentId = nil
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
}

