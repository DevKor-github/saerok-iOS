//
//  BoardView.swift
//  saerok
//
//  Created by HanSeung on 2/3/26.
//

import SwiftUI
import Foundation

// MARK: - ViewModel
extension BoardView {
    @Observable
    final class ViewModel {
        private let interactor: UserInteractor
        
        var announcements: [DTO.Announcement] = []
        
        init(interactor: UserInteractor) {
            self.interactor = interactor
        }
        
        func loadAnnouncements() async {
            do {
                announcements = try await interactor.getAnnouncements()
            } catch { }
        }
        
        func loadAnnouncementDetail(id: Int) async throws -> DTO.AnnouncementDetail {
            return try await interactor.getAnnouncementDetail(id)
        }
    }
}

// MARK: - View
struct BoardView: View {
    typealias Route = MyPageRoute
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationBar
            boardList
            Spacer()
        }
        .ignoresSafeArea(edges: [.bottom])
        .regainSwipeBack()
        .task { await viewModel.loadAnnouncements() }
    }
    
    private var navigationBar: some View {
        NavigationBar(
            center: {
                Text("공지사항")
                    .font(.SRFontSet.subtitle2)
            }, leading: {
                Button {
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.default)
                }
                .srStyled(.borderedIconButton)
            })
    }
    
    private var boardList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.announcements, id: \.id) { item in
                    BoardCell(item: item)
                        .onTapGesture {
                            coordinator.push(Route.boardDetail(id: item.id))
                        }
                }
            }
        }
    }
}

// MARK: - BoardCell
struct BoardCell: View {
    typealias Item = DTO.Announcement
    
    let item: Item
    
    var body: some View {
        HStack(spacing: 21) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.SRFontSet.body2_3)
                    .foregroundStyle(.primary)
                Text("\(item.publishedAt.timeAgoText) | 새록운영팀")
                    .font(.SRFontSet.caption3)
                    .foregroundStyle(.srGray)
            }
            Spacer()
            Image.SRIconSet.chevronRight
                .frame(.default, tintColor: .primary)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .background(Color.srWhite)
        .overlay(alignment: .top) {
            divider
        }
        .overlay(alignment: .bottom) {
            divider
                .offset(y: 1)
        }
        .contentShape(Rectangle())
    }
    
    private let divider: some View = {
        Rectangle()
            .fill(Color.srLightGray)
            .frame(height: 1)
    }()
}
