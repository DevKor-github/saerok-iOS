//
//  CommunityPostDetailViewModel.swift
//  saerok
//
//  Created by HanSeung on 3/13/26.
//

import Foundation

extension CommunityPostDetailView {
    @Observable
    final class ViewModel {
        enum Output: Equatable {
            case postDeleted
            case reportSubmitted
        }

        private(set) var post: Local.FreeBoardPost?
        private(set) var comments: [Local.CollectionComment] = []
        private(set) var isMyPost: Bool = false
        private(set) var isLoading: Bool = false
        var commentText: String = ""
        var selectedComment: Local.CollectionComment?
        private(set) var output: Output?

        let postId: Int
        private let interactor: CommunityInteractor
        private let appState: Store<AppState>

        var currentUserNickname: String { appState[\.currentUser]?.nickname ?? "" }
        var isGuest: Bool { appState[\.authStatus] == .guest }

        init(postId: Int, interactor: CommunityInteractor, appState: Store<AppState>) {
            self.postId = postId
            self.interactor = interactor
            self.appState = appState
        }

        func load() async {
            isLoading = true
            do {
                async let postTask = interactor.fetchFreeboardPost(postId: postId)
                async let commentsTask = interactor.fetchFreeboardComments(postId: postId, page: nil, size: nil)
                let (fetchedPost, fetchedComments) = try await (postTask, commentsTask)
                post = fetchedPost
                isMyPost = fetchedComments.isMyPost
                comments = fetchedComments.items.map {
                    .from(freeBoardComment: $0, isMyPost: fetchedComments.isMyPost)
                }
            } catch {}
            isLoading = false
        }

        func submitComment() async {
            let text = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            do {
                _ = try await interactor.createFreeboardComment(
                    postId: postId,
                    content: text,
                    parentId: selectedComment?.id
                )
                commentText = ""
                selectedComment = nil
                await reloadComments()
            } catch {}
        }

        func deleteComment(_ commentId: Int) async {
            do {
                try await interactor.deleteFreeboardComment(postId: postId, commentId: commentId)
                await reloadComments()
            } catch {}
        }

        func deletePost() async {
            do {
                try await interactor.deleteFreeboardPost(postId: postId)
                output = .postDeleted
            } catch {}
        }

        func reportPost() async {
            do {
                _ = try await interactor.reportFreeboardPost(postId: postId)
                output = .reportSubmitted
            } catch {}
        }

        private func reloadComments() async {
            do {
                let result = try await interactor.fetchFreeboardComments(postId: postId, page: nil, size: nil)
                isMyPost = result.isMyPost
                comments = result.items.map { .from(freeBoardComment: $0, isMyPost: result.isMyPost) }
            } catch {}
        }
    }
}
