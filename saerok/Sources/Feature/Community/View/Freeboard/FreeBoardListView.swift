//
//  FreeBoardListView.swift
//  saerok
//
//  Created by HanSeung on 5/5/26.
//

import Foundation
import Combine
import SwiftUI

struct FreeBoardListView: View {
    private enum PendingPostAction {
        case delete
        case report
    }

    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.showToast) private var showToast
    @State private var viewModel: ViewModel
    @State private var showPostingView: Bool = false
    @State private var showFloatingMenu: Bool = false
    @State private var showPostActionPopup: Bool = false
    @State private var selectedPost: Local.FreeBoardPost?
    @State private var pendingPostAction: PendingPostAction?

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .task { await viewModel.loadInitialIfNeeded() }
            .regainSwipeBack()
            .srPopup(isPresented: $showPostActionPopup, config: postActionPopupConfig)
            .sheet(isPresented: $showPostingView) {
                PostingView(
                    nickname: viewModel.currentUserNickname,
                    profileImageUrl: viewModel.currentUserProfileImageUrl,
                    isPresented: $showPostingView,
                    onPost: { content in
                        do {
                            try await viewModel.createPost(content: content)
                            showToast(
                                .init(
                                    type: .success,
                                    message: "게시글을 올렸어요.",
                                    placementOffset: -120,
                                    transitionOffset: 160,
                                    duration: 3.0
                                )
                            )
                        } catch {
                            showToast(
                                .init(
                                    type: .failure,
                                    message: "게시글 업로드에 실패했어요.",
                                    placementOffset: -120,
                                    transitionOffset: 160,
                                    duration: 3.0
                                )
                            )
                        }
                    }
                )
            }
    }

    private var content: some View {
        VStack(spacing: 0) {
            navigationBar
            Divider()
                .frame(height: 1)
                .foregroundStyle(.srLightGray)
            postList
        }
        .modifier(
            FloatingMenuModifier(
                postAction: { showPostingView = true },
                saerokAction: {},
                bottomOffset: 24,
                showMenu: $showFloatingMenu,
                isHidden: $showPostingView
            )
        )
    }

    private var postActionPopupConfig: PopupConfig? {
        guard let selectedPost, let pendingPostAction else { return nil }

        switch pendingPostAction {
        case .delete:
            return .init(
                title: "게시글을 삭제하시겠어요?",
                message: "\(formatText(selectedPost.content))게시글이 삭제돼요.",
                buttons: .double(
                    .init(title: "취소", style: .confirm) { dismissPostActionPopup() },
                    .init(title: "삭제하기", style: .delete) {
                        Task { await deletePost(selectedPost.id) }
                    }
                )
            )
        case .report:
            return .init(
                title: "게시글을 신고하시겠어요?",
                message: "커뮤니티 가이드에 따라\n신고 사유에 해당하는지 검토 후 처리돼요.",
                buttons: .double(
                    .init(title: "신고하기", style: .delete) {
                        Task { await reportPost(selectedPost.id) }
                    },
                    .init(title: "돌아가기", style: .confirm) { dismissPostActionPopup() }
                )
            )
        }
    }

    private var navigationBar: some View {
        NavigationBar(
            center: {
                HStack(spacing: 6) {
                    Image.SRIconSet.post
                        .frame(.default, tintColor: nil)
                        .padding(4)
                        .background(Color.srGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("도란도란")
                        .font(.SRFontSet.subtitle2)
                }
            },
            leading: {
                Button { coordinator.pop() } label: {
                    Image.SRIconSet.chevronLeft.frame(.default)
                }
                .srStyled(.borderedIconButton)
            }
        )
    }

    private var postList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                    PostCell(
                        post: post,
                        onTap: {
                            coordinator.push(CommunityView.Route.postDetail(postId: post.id))
                        },
                        onDelete: {
                            presentPostActionPopup(post: post, action: .delete)
                        },
                        onReport: {
                            presentPostActionPopup(post: post, action: .report)
                        }
                    )
                    .onAppear {
                        if index == viewModel.posts.count - 1 {
                            Task { await viewModel.loadMore() }
                        }
                    }
                }
                if viewModel.isLoading {
                    ProgressView().padding()
                }
            }
        }
        .refreshable { await viewModel.refresh() }
    }

    private func deletePost(_ postId: Int) async {
        dismissPostActionPopup()
        do {
            try await viewModel.deletePost(postId)
            showToast(.init(type: .success, message: "게시글을 삭제했어요.", placementOffset: -120, transitionOffset: 160, duration: 3.0))
        } catch {
            showToast(.init(type: .failure, message: "게시글 삭제에 실패했어요.", placementOffset: -120, transitionOffset: 160, duration: 3.0))
        }
    }

    private func reportPost(_ postId: Int) async {
        dismissPostActionPopup()
        do {
            try await viewModel.reportPost(postId)
            showToast(.init(type: .success, message: "게시글을 신고했어요.", placementOffset: -120, transitionOffset: 160, duration: 3.0))
        } catch {
            showToast(.init(type: .failure, message: "게시글 신고에 실패했어요.", placementOffset: -120, transitionOffset: 160, duration: 3.0))
        }
    }

    private func presentPostActionPopup(post: Local.FreeBoardPost, action: PendingPostAction) {
        selectedPost = post
        pendingPostAction = action
        showPostActionPopup = true
    }

    private func dismissPostActionPopup() {
        showPostActionPopup = false
        selectedPost = nil
        pendingPostAction = nil
    }

    private func formatText(_ text: String?) -> String {
        let limit = 10
        guard let text else { return "" }

        if text.count <= limit {
            return "'\(text)...'"
        } else {
            let truncated = text.prefix(limit)
            return "'\(truncated)...'"
        }
    }
}

extension FreeBoardListView {
    @Observable
    final class ViewModel {
        private(set) var posts: [Local.FreeBoardPost] = []
        private(set) var isLoading: Bool = false
        private(set) var hasNext: Bool = true
        private(set) var didLoad: Bool = false
        private(set) var currentPage: Int = 1
        private(set) var currentUser: AppState.UserProfile?

        private let interactor: CommunityInteractor
        private let appStore: AppStore
        private let size: Int = 20
        private let cancelBag = CancelBag()

        var currentUserNickname: String { currentUser?.nickname ?? "" }
        var currentUserProfileImageUrl: String? { currentUser?.imageURL }

        init(interactor: CommunityInteractor, appStore: AppStore) {
            self.interactor = interactor
            self.appStore = appStore
            self.currentUser = appStore[\.currentUser]

            appStore
                .updates(for: \.currentUser)
                .weakSink(on: self) { viewModel, user in
                    viewModel.currentUser = user
                }
                .store(in: cancelBag)

            appStore.events
                .compactMap { event -> Int? in
                    guard case .freeBoardPostDeleted(let postId) = event else { return nil }
                    return postId
                }
                .weakSink(on: self) { viewModel, postId in
                    viewModel.removePost(postId)
                }
                .store(in: cancelBag)
        }

        func loadInitialIfNeeded() async {
            guard !didLoad else { return }
            didLoad = true
            await loadInitial()
        }

        func refresh() async {
            didLoad = false
            await loadInitialIfNeeded()
        }

        func loadMore() async {
            guard !isLoading, hasNext else { return }
            isLoading = true
            do {
                let result = try await interactor.fetchFreeboardPosts(page: currentPage, size: size)
                posts.append(contentsOf: result.items)
                hasNext = result.hasNext
                if result.hasNext { currentPage += 1 }
            } catch {
                hasNext = false
            }
            isLoading = false
        }

        func createPost(content: String) async throws {
            _ = try await interactor.createFreeboardPost(content: content)
            didLoad = false
            await loadInitialIfNeeded()
        }

        func deletePost(_ postId: Int) async throws {
            try await interactor.deleteFreeboardPost(postId: postId)
            appStore.send(.notifyFreeBoardPostDeleted(postId))
        }

        func reportPost(_ postId: Int) async throws {
            _ = try await interactor.reportFreeboardPost(postId: postId)
        }

        private func loadInitial() async {
            currentPage = 1
            hasNext = true
            posts = []
            await loadMore()
        }

        private func removePost(_ postId: Int) {
            posts.removeAll { $0.id == postId }
        }
    }
}
