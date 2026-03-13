//
//  CollectionRepository.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//

import SwiftData
import Foundation

protocol CollectionRepository {
    func fetchCollectionSummaries() async throws -> [Local.CollectionSummary]
    func fetchCollectionDetail(for id: Int) async throws -> Local.CollectionDetail
    func createCollection(_ request: DTO.CreateCollectionRequest) async throws -> Int
    func getPresignedURL(collectionId: Int, contentType: String) async throws -> DTO.PresignedURLResponse
    func registerImageMetadata(collectionId: Int, request: DTO.RegisterImageRequest) async throws -> DTO.RegisterImageResponse
    func deleteCollection(_ id: Int) async throws
    func editCollection(id: Int, isBirdUpdated: Bool, _ draft: Local.CollectionDraft) async throws
    func fetchCollectionComments(_ id: Int) async throws -> [Local.CollectionComment]
    func createCollectionComment(id: Int, parentId: Int?, _ content: String) async throws
    func toggleCollectionLike(_ id: Int) async throws -> Bool
    func fetchLikeUsers(_ id: Int) async throws -> DTO.CollectionLikeUsersResponse
    func deleteCollectionComment(collectionId: Int, commentId: Int) async throws
    func reportCollection(_ id: Int) async throws
    func reportComment(_ collectionId: Int, commentId: Int) async throws
    func fetchBirdSuggestions(collectionId: Int) async throws -> [Local.BirdSuggestion]
    func suggestBird(collectionId: Int, birdId: Int) async throws
    func toggleSuggestionAgree(collectionId: Int, birdId: Int) async throws -> DTO.ToggleSuggestionResponse
    func toggleSuggestionDisagree(collectionId: Int, birdId: Int) async throws -> DTO.ToggleSuggestionResponse
    func adoptSuggestion(collectionId: Int, birdId: Int) async throws
    func resetSuggestion(collectionId: Int) async throws
}


extension MainRepository: CollectionRepository {
    func fetchCollectionSummaries() async throws -> [Local.CollectionSummary] {
        let collectionSummaryDTOs: DTO.MyCollectionsResponse = try await networkService.performSRRequest(
            .myCollections
        )
        return collectionSummaryDTOs.items.compactMap {
            Local.CollectionSummary.from(dto: $0)
        }
    }

    func fetchCollectionDetail(for id: Int) async throws -> Local.CollectionDetail {
        let collectionDetailDTO: DTO.CollectionDetailResponse = try await networkService.performSRRequest(
            .collectionDetail(collectionId: id)
        )
        return Local.CollectionDetail.from(dto: collectionDetailDTO)
    }

    func createCollection(_ request: DTO.CreateCollectionRequest) async throws -> Int {
        let response: DTO.CreateCollectionResponse = try await networkService.performSRRequest(
            .createCollection(body: request)
        )
        return response.collectionId
    }

    func getPresignedURL(
        collectionId: Int,
        contentType: String
    ) async throws -> DTO.PresignedURLResponse {
        try await networkService.performSRRequest(
            .getPresignedURL(collectionId: collectionId, contentType: contentType)
        )
    }

    func registerImageMetadata(
        collectionId: Int,
        request: DTO.RegisterImageRequest
    ) async throws -> DTO.RegisterImageResponse {
        try await networkService.performSRRequest(
            .registerUploadedImage(collectionId: collectionId, body: request)
        )
    }

    func deleteCollection(_ id: Int) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .deleteCollection(collectionId: id)
        )
    }

    func editCollection(
        id: Int,
        isBirdUpdated: Bool,
        _ draft: Local.CollectionDraft
    ) async throws {
        let dto = draft.toEditDTO(isBirdUpdated: isBirdUpdated)
        let _: DTO.CollectionEditResponse = try await networkService.performSRRequest(
            .editCollection(collectionId: id, body: dto)
        )
    }

    func fetchCollectionComments(_ id: Int) async throws -> [Local.CollectionComment] {
        let collectionCommentDTO: DTO.CollectionCommentsResponse = try await networkService.performSRRequest(
            .collectionComments(collectionId: id)
        )
        return Local.CollectionComment.from(dto: collectionCommentDTO)
    }

    func createCollectionComment(id: Int, parentId: Int?, _ content: String) async throws {
        let _: DTO.CreateCommentResponse = try await networkService.performSRRequest(
            .createComment(
                collectionId: id,
                body: .init(content: content, parentId: parentId)
            )
        )
    }
    


    func toggleCollectionLike(_ id: Int) async throws -> Bool {
        let result: DTO.CollectionLikeToggleResponse = try await networkService.performSRRequest(
            .likeCollection(collectionId: id)
        )
        return result.isLiked
    }
    
    func fetchLikeUsers(_ id: Int) async throws -> DTO.CollectionLikeUsersResponse {
        let result: DTO.CollectionLikeUsersResponse = try await networkService.performSRRequest(
            .collectionLikeUsers(collectionId: id)
        )
        return result
    }

    func deleteCollectionComment(
        collectionId: Int,
        commentId: Int
    ) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .deleteCollectionComment(
                collectionID: collectionId,
                commentID: commentId
            )
        )
    }
    
    func reportCollection(_ id: Int) async throws{
        let _: EmptyResponse = try await networkService.performSRRequest(
            .reportCollection(collectionId: id)
        )
    }

    func reportComment(_ collectionId: Int, commentId: Int) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .reportComment(collectionId: collectionId, commentId: commentId)
        )
    }
    
    func fetchBirdSuggestions(collectionId: Int) async throws -> [Local.BirdSuggestion] {
        let result: DTO.SuggestionListResponse = try await networkService.performSRRequest(
            .getSuggestions(collectionId: collectionId)
        )
        let birds = try modelContext.fetch(FetchDescriptor<Local.Bird>())
        
        return Local.BirdSuggestion.from(
            dto: result,
            existingBirds: birds
        )
    }
    
    func suggestBird(collectionId: Int, birdId: Int) async throws {
        let _: DTO.SuggestResponse = try await networkService.performSRRequest(
            .suggestBird(collectionId: collectionId, birdId: birdId)
        )
    }
    
    func adoptSuggestion(collectionId: Int, birdId: Int) async throws {
        let _: DTO.AdoptSuggestionResponse = try await networkService.performSRRequest(
            .adoptSuggestion(collectionId: collectionId, birdId: birdId)
        )
    }
    
    func toggleSuggestionAgree(collectionId: Int, birdId: Int) async throws -> DTO.ToggleSuggestionResponse {
        let result: DTO.ToggleSuggestionResponse = try await networkService.performSRRequest(
            .toggleSuggestionAgree(collectionId: collectionId, birdId: birdId)
        )
        return result
    }
    
    func toggleSuggestionDisagree(collectionId: Int, birdId: Int) async throws -> DTO.ToggleSuggestionResponse {
        let result: DTO.ToggleSuggestionResponse = try await networkService.performSRRequest(
            .toggleSuggestionDisagree(collectionId: collectionId, birdId: birdId)
        )
        return result
    }
    
    func resetSuggestion(collectionId: Int) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .resetSuggestion(collectionId: collectionId)
        )
    }
}
