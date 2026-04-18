//
//  CommunityDetailView.swift
//  saerok
//
//  Created by HanSeung on 9/24/25.
//

import SwiftUI

struct CommunityDetailView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .task { await viewModel.loadInitialIfNeeded() }
            .regainSwipeBack()
    }

    private var content: some View {
        VStack(spacing: 0) {
            navigationBar
            Divider()
                .frame(height: 1)
                .foregroundStyle(.srGray)
            itemList
        }
    }

    private var navigationBar: some View {
        NavigationBar(
            center: {
                barIcon
                Text(viewModel.type.title)
                    .font(.SRFontSet.subtitle2)
            },
            leading: {
                Button {
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft.frame(.defaultIconSize)
                }
                
                .srStyled(.borderedIconButton)
            }
        )
    }

    @ViewBuilder
    private var barIcon: some View {
        switch viewModel.type {
        case .recent:
            barIconStyle(icon: .commentCommunity, background: .accent)
        case .popular:
            barIconStyle(icon: .fire, background: .fire)
        case .suggestion:
            barIconStyle(icon: .unknown, background: .pointtext)
            #if DEBUG
        case .board:
            barIconStyle(icon: .post, background: .srGreen)
            #endif
        case .search:
            EmptyView()
        }
    }
    
    private func barIconStyle(icon: Image.SRIconSet, background: Color) -> some View {
        icon
            .frame(.defaultIconSize, tintColor: icon == .unknown ? .srWhite : nil)
            .padding(4)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var itemList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                switch viewModel.type {
                #if DEBUG
                case .board:
                    ForEach(CommunityDetailView.mockPosts, id: \.id) { post in
                        Button {
                            coordinator.push(CommunityView.Route.postDetail(post: post))
                        } label: {
                            PostCell(post: post)
                        }
                        .buttonStyle(.plain)
                    }
                #endif
                default:
                    ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                        Button {
                            coordinator.push(CommunityView.Route.detailFromFeed(id: item.id))
                        } label: {
                            CommunityCell(item: item, type: viewModel.type)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if index == viewModel.items.count - 1 {
                                Task { await viewModel.loadMore() }
                            }
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView().padding()
                }
            }
        }
    }
}

extension DTO {
    struct Post: Decodable {
        let id: Int
        let title: String
        let content: String
        let author: DTO.User
        let likeCount: Int
        let commentCount: Int
        let isLiked: Bool
        let createdAt: String
    }
    
    struct PostListResponseDTO: Decodable {
        let posts: [Post]
        let hasNext: Bool
    }
    
    struct PostCreateRequestDTO: Encodable {
        let title: String
        let content: String
    }
}

extension DTO.Post: Hashable {
    static func == (lhs: DTO.Post, rhs: DTO.Post) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
