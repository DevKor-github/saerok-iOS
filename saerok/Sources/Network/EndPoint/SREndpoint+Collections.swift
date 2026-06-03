//
//  SREndpoint+Collections.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

// MARK: - Collections API

extension SREndpoint {
    static var myCollections: SREndpoint {
        SREndpoint(path: "collections/me", auth: .required, response: DTO.MyCollectionsResponse.self)
    }

    static func collectionDetail(collectionId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)",
            auth: .ifLoggedIn,
            response: DTO.CollectionDetailResponse.self
        )
    }

    static func nearbyCollections(
        lat: Double,
        lng: Double,
        radius: Double,
        isMineOnly: Bool,
        isGuest: Bool = false
    ) -> SREndpoint {
        SREndpoint(
            path: "collections/nearby",
            auth: isGuest ? .none : .required,
            query: [
                "latitude": "\(lat)",
                "longitude": "\(lng)",
                "radiusMeters": "\(radius)",
                "isMineOnly": "\(isMineOnly)"
            ],
            response: DTO.NearbyCollectionsResponse.self
        )
    }

    static func createCollection(body: DTO.CreateCollectionRequest) -> SREndpoint {
        SREndpoint(
            path: "collections/",
            method: .post,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.CreateCollectionResponse.self
        )
    }

    static func getPresignedURL(collectionId: Int, contentType: String) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/images/presign",
            method: .post,
            auth: .required,
            body: jsonBody(["contentType": contentType]),
            json: true,
            response: DTO.PresignedURLResponse.self
        )
    }

    static func registerUploadedImage(collectionId: Int, body: DTO.RegisterImageRequest) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/images",
            method: .post,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.RegisterImageResponse.self
        )
    }

    static func deleteCollection(collectionId: Int) -> SREndpoint {
        SREndpoint(path: "collections/\(collectionId)", method: .delete, auth: .required)
    }

    static func editCollection(collectionId: Int, body: DTO.EditCollectionMetadataRequest) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/edit",
            method: .patch,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.CollectionEditResponse.self
        )
    }

    static func collectionComments(collectionId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/comments",
            auth: .required,
            response: DTO.CollectionCommentsResponse.self
        )
    }

    static func createComment(collectionId: Int, body: DTO.CreateCommentRequest) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/comments",
            method: .post,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.CreateCommentResponse.self
        )
    }

    static func likeCollection(collectionId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/like",
            method: .post,
            auth: .required,
            response: DTO.CollectionLikeToggleResponse.self
        )
    }

    static func deleteCollectionComment(collectionID: Int, commentID: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionID)/comments/\(commentID)",
            method: .delete,
            auth: .required
        )
    }

    static func reportCollection(collectionId: Int) -> SREndpoint {
        SREndpoint(path: "collections/\(collectionId)/report", method: .post, auth: .required)
    }

    static func reportComment(collectionId: Int, commentId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/comments/\(commentId)/report",
            method: .post,
            auth: .required
        )
    }

    static func collectionLikeUsers(collectionId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/like/users",
            auth: .required,
            response: DTO.CollectionLikeUsersResponse.self
        )
    }
}
