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
    
    init(id: Int, viewModel: BoardView.ViewModel) {
        self.postId = id
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .regainSwipeBack()
            .task { await loadDetail() }
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
                .padding(.horizontal, SRDesignConstant.defaultPadding)
                
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
                        .frame(.defaultIconSize)
                }
                .buttonStyle(.borderedIcon)
            },
            backgroundColor: .clear
        )
    }
    
    private func loadDetail() async {
        self.item = try? await viewModel.loadAnnouncementDetail(id: postId)
    }
}



