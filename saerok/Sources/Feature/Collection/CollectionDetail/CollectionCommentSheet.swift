//
//  CollectionCommentSheet.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//

import SwiftUI

struct CollectionCommentSheet: View {
    //사용자 차단
    @AppStorage("blockable") var isBlockable: Bool = false
    
    @Bindable var viewModel: CollectionDetailView.ViewModel
    let collectionId: Int
    let collectionUserId: Int
    let isMyCollection: Bool
    let comments: [Local.CollectionComment]
    @Binding var selectedComment: Local.CollectionComment?
    
    let onTap: (_ userId: Int) -> Void
    let onDelete: (Int) async -> Void
    let onDismiss: () -> Void
    
    @State var showReportCommentPopup: Bool = false
    @State var reportId: Int?
    
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
                            commentThread(for: item)
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
                action: reportComment,
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

    
    func reportComment() {
        guard let reportId = reportId else { return }
        
        Task {
            await viewModel.reportComment(id: reportId)
            self.reportId = nil
            showReportCommentPopup = false
        }
    }

    func blockUser(userId: Int) {
        Task {
            await viewModel.blockUser(userId: userId)
            await viewModel.fetchComments()
        }
    }
    
    private func commentThread(for item: Local.CollectionComment) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            parentCommentView(item)
            repliesView(item)
        }
    }
    
    private func parentCommentView(_ item: Local.CollectionComment) -> some View {
        CollectionCommentCell(
            collectionUserId: collectionUserId,
            isMyCollection: isMyCollection,
            isReply: false,
            isSelected: selectedComment == item,
            item: item,
            onTap: { onTap(item.user.id) },
            onReply: { selectedComment = item },
            onDelete: onDelete,
            onReport: {
                reportId = item.id
                showReportCommentPopup.toggle()
            },
            onBlock: {
                blockUser(userId: item.user.id)
            }
        )
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func repliesView(_ item: Local.CollectionComment) -> some View {
        if let replies = item.replies, !replies.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(replies) { reply in
                    CollectionCommentCell(
                        collectionUserId: collectionUserId,
                        isMyCollection: isMyCollection,
                        isReply: true,
                        isSelected: false,
                        item: reply,
                        onTap: { onTap(reply.user.id) },
                        onReply: {},
                        onDelete: onDelete,
                        onReport: {
                            reportId = item.id
                            showReportCommentPopup.toggle()
                        },
                        onBlock: {
                            blockUser(userId: reply.user.id)
                        }
                    )
                }
            }
        }
    }
}
