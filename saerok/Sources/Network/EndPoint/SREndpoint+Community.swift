//
//  SREndpoint+Community.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

// MARK: - Community API

extension SREndpoint {
    static var communityMain: SREndpoint {
        SREndpoint(path: "community/main", response: DTO.CommunityMainResponse.self)
    }

    static func communityPendingBirdId(page: Int? = nil, size: Int? = nil) -> SREndpoint {
        SREndpoint(
            path: "community/pending-bird-id",
            query: pageQuery(page: page, size: size),
            response: DTO.CommunityPendingBirdIdResponse.self
        )
    }

    static func communityPopular(page: Int? = nil, size: Int? = nil) -> SREndpoint {
        SREndpoint(
            path: "community/popular",
            query: pageQuery(page: page, size: size),
            response: DTO.CommunityPopularResponse.self
        )
    }

    static func communityRecent(page: Int? = nil, size: Int? = nil) -> SREndpoint {
        SREndpoint(
            path: "community/recent",
            query: pageQuery(page: page, size: size),
            response: DTO.CommunityRecentResponse.self
        )
    }

    static func communitySearch(query: String) -> SREndpoint {
        SREndpoint(
            path: "community/search",
            query: ["q": query],
            response: DTO.CommunitySearchResponse.self
        )
    }

    static func communitySearchUsers(query: String, page: Int? = nil, size: Int? = nil) -> SREndpoint {
        SREndpoint(
            path: "community/search/users",
            query: searchQuery(query: query, page: page, size: size),
            response: DTO.CommunitySearchUsersResponse.self
        )
    }

    static func communitySearchCollections(query: String, page: Int? = nil, size: Int? = nil) -> SREndpoint {
        SREndpoint(
            path: "community/search/collections",
            query: searchQuery(query: query, page: page, size: size),
            response: DTO.CommunitySearchCollectionsResponse.self
        )
    }

    static func communityFreeboardPosts(page: Int? = nil, size: Int? = nil) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts",
            auth: .ifLoggedIn,
            query: pageQuery(page: page, size: size),
            response: DTO.CommunityFreeboardPostsResponse.self
        )
    }

    static func createFreeBoardPost(body: DTO.CreateFreeBoardPostRequest) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts",
            method: .post,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.CreateFreeBoardPostResponse.self
        )
    }

    static func freeBoardPost(postId: Int) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts/\(postId)",
            auth: .ifLoggedIn,
            response: DTO.FreeBoardPostItem.self
        )
    }

    static func deleteFreeBoardPost(postId: Int) -> SREndpoint {
        SREndpoint(path: "community/freeboard/posts/\(postId)", method: .delete, auth: .required)
    }

    static func editFreeBoardPost(postId: Int, body: DTO.EditFreeBoardPostRequest) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts/\(postId)",
            method: .patch,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.EditFreeBoardPostResponse.self
        )
    }

    static func freeBoardPostComments(postId: Int, page: Int? = nil, size: Int? = nil) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts/\(postId)/comments",
            auth: .ifLoggedIn,
            query: pageQuery(page: page, size: size),
            response: DTO.FreeBoardCommentsResponse.self
        )
    }

    static func createFreeBoardComment(postId: Int, body: DTO.CreateFreeBoardCommentRequest) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts/\(postId)/comments",
            method: .post,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.CreateFreeBoardCommentResponse.self
        )
    }

    static func deleteFreeBoardComment(postId: Int, commentId: Int) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts/\(postId)/comments/\(commentId)",
            method: .delete,
            auth: .required
        )
    }

    static func editFreeBoardComment(
        postId: Int,
        commentId: Int,
        body: DTO.EditFreeBoardCommentRequest
    ) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts/\(postId)/comments/\(commentId)",
            method: .patch,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.EditFreeBoardCommentResponse.self
        )
    }

    static func freeBoardCommentCount(postId: Int) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts/\(postId)/comments/count",
            response: DTO.FreeBoardCommentCountResponse.self
        )
    }

    static func reportFreeBoardPost(postId: Int) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts/\(postId)/report",
            method: .post,
            auth: .required,
            response: DTO.ReportFreeBoardPostResponse.self
        )
    }
}
