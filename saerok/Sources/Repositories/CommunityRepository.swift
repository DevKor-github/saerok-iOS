//
//  CommunityRepository.swift
//  saerok
//
//  Created by HanSeung on 9/24/25.
//


import Foundation

protocol CommunityRepository {
    func fetchCommunityMain() async throws -> DTO.CommunityMainResponse
    func fetchPendingBirdId(page: Int?, size: Int?) async throws -> DTO.CommunityPendingBirdIdResponse
    func fetchPopular(page: Int?, size: Int?) async throws -> DTO.CommunityPopularResponse
    func fetchRecent(page: Int?, size: Int?) async throws -> DTO.CommunityRecentResponse
    func search(query: String) async throws -> DTO.CommunitySearchResponse
    func searchUsers(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchUsersResponse
    func searchCollections(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchCollectionsResponse
    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> DTO.CommunityFreeboardPostsResponse
    func createFreeboardPost(content: String) async throws -> DTO.CreateFreeBoardPostResponse
    func fetchFreeboardPost(postId: Int) async throws -> DTO.FreeBoardPostItem
    func deleteFreeboardPost(postId: Int) async throws
    func editFreeboardPost(postId: Int, content: String) async throws -> DTO.EditFreeBoardPostResponse
    func fetchFreeboardComments(postId: Int, page: Int?, size: Int?) async throws -> DTO.FreeBoardCommentsResponse
    func createFreeboardComment(postId: Int, content: String, parentId: Int?) async throws -> DTO.CreateFreeBoardCommentResponse
    func deleteFreeboardComment(postId: Int, commentId: Int) async throws
    func editFreeboardComment(postId: Int, commentId: Int, content: String) async throws -> DTO.EditFreeBoardCommentResponse
    func fetchFreeboardCommentCount(postId: Int) async throws -> DTO.FreeBoardCommentCountResponse
    func reportFreeboardPost(postId: Int) async throws -> DTO.ReportFreeBoardPostResponse
}

extension MainRepository: CommunityRepository {
    func fetchCommunityMain() async throws -> DTO.CommunityMainResponse {
        try await networkService.performSRRequest(.communityMain)
    }
    
    func fetchPendingBirdId(page: Int?, size: Int?) async throws -> DTO.CommunityPendingBirdIdResponse {
        try await networkService.performSRRequest(
            .communityPendingBirdId(page: page, size: size)
        )
    }
    
    func fetchPopular(page: Int?, size: Int?) async throws -> DTO.CommunityPopularResponse {
        try await networkService.performSRRequest(
            .communityPopular(page: page, size: size)
        )
    }
    
    func fetchRecent(page: Int?, size: Int?) async throws -> DTO.CommunityRecentResponse {
        try await networkService.performSRRequest(
            .communityRecent(page: page, size: size)
        )
    }
    
    func search(query: String) async throws -> DTO.CommunitySearchResponse {
        try await networkService.performSRRequest(
            .communitySearch(query: query)
        )
    }
    
    func searchUsers(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchUsersResponse {
        try await networkService.performSRRequest(
            .communitySearchUsers(query: query, page: page, size: size)
        )
    }
    
    func searchCollections(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchCollectionsResponse {
        try await networkService.performSRRequest(
            .communitySearchCollections(query: query, page: page, size: size)
        )
    }

    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> DTO.CommunityFreeboardPostsResponse {
        try await networkService.performSRRequest(
            .communityFreeboardPosts(page: page, size: size)
        )
    }

    func createFreeboardPost(content: String) async throws -> DTO.CreateFreeBoardPostResponse {
        try await networkService.performSRRequest(
            .createFreeBoardPost(body: .init(content: content))
        )
    }

    func fetchFreeboardPost(postId: Int) async throws -> DTO.FreeBoardPostItem {
        try await networkService.performSRRequest(.freeBoardPost(postId: postId))
    }

    func deleteFreeboardPost(postId: Int) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(.deleteFreeBoardPost(postId: postId))
    }

    func editFreeboardPost(postId: Int, content: String) async throws -> DTO.EditFreeBoardPostResponse {
        try await networkService.performSRRequest(
            .editFreeBoardPost(postId: postId, body: .init(content: content))
        )
    }

    func fetchFreeboardComments(postId: Int, page: Int?, size: Int?) async throws -> DTO.FreeBoardCommentsResponse {
        try await networkService.performSRRequest(
            .freeBoardPostComments(postId: postId, page: page, size: size)
        )
    }

    func createFreeboardComment(postId: Int, content: String, parentId: Int?) async throws -> DTO.CreateFreeBoardCommentResponse {
        try await networkService.performSRRequest(
            .createFreeBoardComment(postId: postId, body: .init(content: content, parentId: parentId))
        )
    }

    func deleteFreeboardComment(postId: Int, commentId: Int) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(.deleteFreeBoardComment(postId: postId, commentId: commentId))
    }

    func editFreeboardComment(postId: Int, commentId: Int, content: String) async throws -> DTO.EditFreeBoardCommentResponse {
        try await networkService.performSRRequest(
            .editFreeBoardComment(postId: postId, commentId: commentId, body: .init(content: content))
        )
    }

    func fetchFreeboardCommentCount(postId: Int) async throws -> DTO.FreeBoardCommentCountResponse {
        try await networkService.performSRRequest(.freeBoardCommentCount(postId: postId))
    }

    func reportFreeboardPost(postId: Int) async throws -> DTO.ReportFreeBoardPostResponse {
        try await networkService.performSRRequest(.reportFreeBoardPost(postId: postId))
    }
}
