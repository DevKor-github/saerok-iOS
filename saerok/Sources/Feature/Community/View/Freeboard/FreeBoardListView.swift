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
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.showToast) private var showToast
    @State private var viewModel: ViewModel
    @State private var showPostingView: Bool = false

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .task { await viewModel.loadInitialIfNeeded() }
            .regainSwipeBack()
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
                                    placementOffset: -58,
                                    transitionOffset: 160,
                                    duration: 2.0
                                )
                            )
                        } catch {
                            showToast(
                                .init(
                                    type: .failure,
                                    message: "게시글 업로드에 실패했어요.",
                                    placementOffset: -58,
                                    transitionOffset: 160,
                                    duration: 2.0
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
        .overlay(alignment: .bottomTrailing) {
            FreeboardAddButton { showPostingView = true }
                .padding(.trailing, 23)
                .padding(.bottom, 34)
                .opacity(showPostingView ? 0 : 1)
        }
        .ignoresSafeArea(edges: .bottom)
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
            BannerView()
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                    PostCell(
                        post: post,
                        onTap: {
                            coordinator.push(CommunityView.Route.postDetail(postId: post.id))
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

}

// MARK: - Freeboard Add Button

struct FreeboardAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.splash)
                .frame(width: 62, height: 62)
                .overlay {
                    Image.SRIconSet.freeboardAdd
                        .frame(.custom(CGSize(width: 34, height: 34)))
                }
                .srShadow(.floating25)
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
