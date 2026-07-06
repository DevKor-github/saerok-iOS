//
//  BoardDetailView.swift
//  saerok
//
//  Created by HanSeung on 2/3/26.
//

import SwiftUI
import Foundation

struct BoardDetailView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.openURL) private var openURL
    
    private let postId: Int
    @State var viewModel: BoardView.ViewModel
    @State private var item: DTO.AnnouncementDetail?
    @State private var showPopup: Bool = false
    
    init(id: Int, viewModel: BoardView.ViewModel) {
        self.postId = id
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .regainSwipeBack()
            .task {
                await loadDetail()
            }
            .srPopup(
                isPresented: $showPopup,
                config: showPopup ? deletedNoticePopupConfig : nil
            )
    }
    
    @ViewBuilder
    private var content: some View {
        if let item = item {
            ZStack(alignment: .topLeading) {
                Color.srWhite.edgesIgnoringSafeArea(.all)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.title)
                            .font(.SRFontSet.headline2_3)
                            .padding(.vertical, 12)
                        Text("\(item.publishedAt.timeAgoText) | 새록운영팀")
                            .font(.SRFontSet.body1)
                            .foregroundStyle(.srGray)
                            .padding(.bottom, 29)
                        NoticeContentView(nodes: NoticeHTMLParser.parse(item.content))
                            .foregroundStyle(.srDarkGray)
                    }
                    .padding(.vertical, 60)
                }
                .padding(.horizontal, SRSpacing.screenHorizontal)
                
                navigationBar
                    .background(Color.clear)
            }
            .frame(maxWidth: .infinity)
        } else {
            navigationBar
            ProgressView()
        }
    }
    
    private var navigationBar: some View {
        NavigationBar(
            leading: {
                Button {
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.default)
                }
                .srStyled(.borderedIconButton)
            },
            backgroundColor: .clear
        )
    }
    
    private var deletedNoticePopupConfig: PopupConfig {
        PopupConfig(
            title: "오류가 발생했어요",
            message: "삭제된 공지사항입니다.",
            buttons: .single(
                .init(
                    title: "확인",
                    style: .confirm,
                    action: {
                        showPopup = false
                        coordinator.pop()
                    }
                )
            )
        )
    }
    
    private func loadDetail() async {
        do {
            self.item = try await viewModel.loadAnnouncementDetail(id: postId)
        } catch {
            showPopup = true
        }
    }
}
