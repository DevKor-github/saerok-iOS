//
//  CollectionInteractor.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//

protocol CollectionInteractor {
    func fetchMyCollections() async throws -> [Local.CollectionSummary]
    func fetchCollectionDetail(id: Int) async throws -> Local.CollectionDetail
    func createCollection(_ draft: Local.CollectionDraft) async throws
    func deleteCollection(_ id: Int) async throws
    func editCollection(_ draft: Local.CollectionDraft) async throws
    func fetchComments(_ id: Int) async throws -> [Local.CollectionComment]
    func createComments(id: Int, _ content: String) async throws
    func deleteComment(collectionId: Int, commentId: Int) async throws
    func toggleLike(_ id: Int) async throws -> Bool
    func fetchLikeUsers(_ id: Int) async throws -> [Local.UserSummary]
    func reportCollection(_ id: Int) async throws
    func reportComment(collecionId: Int, commentId: Int) async throws

    func fetchBirdSuggestions(_ id: Int) async throws -> [Local.BirdSuggestion]
    func suggestBird(_ id: Int, birdId: Int) async throws -> Local.BirdSuggestion
    func toggleAgree(_ id: Int, suggestion: Local.BirdSuggestion) async throws -> Local.BirdSuggestion
    func toggleDisagree(_ id: Int, suggestion: Local.BirdSuggestion) async throws -> Local.BirdSuggestion
    func adoptSuggestion(_ id: Int, birdId: Int) async throws
    func resetSuggestion(_ id: Int) async throws
}

enum CollectionInteractorError: Error {
    case networkError(NetworkError)
    case decodingError(Error)
    case collectionNotFound
    case unknownError(Error)
    case invalidImageData
}

struct CollectionInteractorImpl: CollectionInteractor {
    let repository: CollectionRepository
    
    func fetchMyCollections() async throws -> [Local.CollectionSummary] {
        try await repository.fetchCollectionSummaries()
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchCollectionDetail(id: Int) async throws -> Local.CollectionDetail {
        return try await repository.fetchCollectionDetail(for: id)
    }
    
    func createCollection(_ draft: Local.CollectionDraft) async throws {
        guard let image = draft.image,
              let jpegData = ImageUploadPreprocessor.prepareJPEGDataForUpload(from: image)
        else { throw CollectionInteractorError.invalidImageData }
        
        let createResponse = try await repository.createCollection(draft.toDTO())
        let presigned = try await repository.getPresignedURL(collectionId: createResponse.collectionId, contentType: "image/jpeg")
        try await S3Uploader.uploadImage(to: presigned.presignedUrl, data: jpegData)
        let registerRequest = DTO.RegisterImageRequest(objectKey: presigned.objectKey, contentType: "image/jpeg")
        let _ = try await repository.registerImageMetadata(collectionId: createResponse.collectionId, request: registerRequest)
    }
    
    func deleteCollection(_ id: Int) async throws {
        try await repository.deleteCollection(id)
    }
    
    func editCollection(_ draft: Local.CollectionDraft) async throws {
        guard let id = draft.collectionID else { throw CollectionInteractorError.collectionNotFound }
        
        let isBirdUpdated = draft.originalBirdId != draft.bird?.id
        try await repository.editCollection(id: id, isBirdUpdated: isBirdUpdated, draft)
    }
    
    func fetchComments(_ id: Int) async throws -> [Local.CollectionComment] {
        return try await repository.fetchCollectionComments(id)
    }
    
    func createComments(id: Int, _ content: String) async throws {
        try await repository.createCollectionComment(id: id, content)
    }
    
    func deleteComment(collectionId: Int, commentId: Int) async throws {
        try await repository.deleteCollectionComment(collectionId: collectionId, commentId: commentId)
    }
    
    func toggleLike(_ id: Int) async throws -> Bool {
        return try await repository.toggleCollectionLike(id)
    }
    
    func fetchLikeUsers(_ id: Int) async throws -> [Local.UserSummary] {
        let users = try await repository.fetchLikeUsers(id)
        return users.items.map {
            .init(id: $0.userId, nickname: $0.nickname, profileImageUrl: $0.profileImageUrl)
        }
    }
    
    func reportCollection(_ id: Int) async throws {
        try await repository.reportCollection(id)
    }
    
    func reportComment(collecionId: Int, commentId: Int) async throws {
        try await repository.reportComment(collecionId, commentId: commentId)
    }

    func fetchBirdSuggestions(_ id: Int) async throws -> [Local.BirdSuggestion] {
        return try await repository.fetchBirdSuggestions(collectionId: id)
    }
    
    func suggestBird(_ id: Int, birdId: Int) async throws -> Local.BirdSuggestion {
        try await repository.suggestBird(collectionId: id, birdId: birdId)
        
        return Local.BirdSuggestion(
            bird: .mockData,
            agreeCount: 1,
            disagreeCount: 0,
            isAgreed: true,
            isDisagreed: false
        )
    }
    
    func toggleAgree(_ id: Int, suggestion: Local.BirdSuggestion) async throws -> Local.BirdSuggestion {
        let result = try await repository.toggleSuggestionAgree(collectionId: id, birdId: suggestion.bird.id)
        return suggestion.update(from: result)
    }
    
    func toggleDisagree(_ id: Int, suggestion: Local.BirdSuggestion) async throws -> Local.BirdSuggestion {
        let result = try await repository.toggleSuggestionDisagree(collectionId: id, birdId: suggestion.bird.id)
        return suggestion.update(from: result)
    }
    
    func adoptSuggestion(_ id: Int, birdId: Int) async throws {
        try await repository.adoptSuggestion(collectionId: id, birdId: birdId)
    }
    
    func resetSuggestion(_ id: Int) async throws {
        try await repository.resetSuggestion(collectionId: id)
    }
}

struct MockCollectionInteractorImpl: CollectionInteractor {
    func reportComment(collecionId: Int, commentId: Int) async throws { }
    
    func fetchLikeUsers(_ id: Int) async throws -> [Local.UserSummary] { [] }
    
    func editCollection(_ draft: Local.CollectionDraft) async throws { }

    func deleteCollection(_ id: Int) async throws { }
    
    func createCollection(_ draft: Local.CollectionDraft) async throws { }
    
    func fetchMyCollections() async throws -> [Local.CollectionSummary] { [] }
    
    func fetchCollectionDetail(id: Int) async throws -> Local.CollectionDetail {
        return Local.CollectionDetail.mockData[0]
    }
    
    func createCollection(_ request: DTO.CreateCollectionRequest) async throws -> DTO.CreateCollectionResponse {
        return .init(collectionId: 0)
    }
    
    func fetchComments(_ id: Int) async throws -> [Local.CollectionComment] { [] }
    
    func createComments(id: Int, _ content: String) async throws { }
    
    func deleteComment(collectionId: Int, commentId: Int) async throws { }
    
    func toggleLike(_ id: Int) async throws -> Bool { true }
    
    func reportCollection(_ id: Int) async throws { }

    func fetchBirdSuggestions(_ id: Int) async throws -> [Local.BirdSuggestion] { [] }
    
    func suggestBird(_ id: Int, birdId: Int) async throws -> Local.BirdSuggestion { Local.BirdSuggestion.mockData[0] }
    
    func adoptSuggestion(_ id: Int, birdId: Int) async throws { }
    
    func toggleAgree(_ id: Int, suggestion: Local.BirdSuggestion) async throws -> Local.BirdSuggestion {
        Local.BirdSuggestion.mockData[0]
    }
    
    func toggleDisagree(_ id: Int, suggestion: Local.BirdSuggestion) async throws -> Local.BirdSuggestion {
        Local.BirdSuggestion.mockData[0]
    }
    
    func resetSuggestion(_ id: Int) async throws { }
}

