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
    func fetchNearbyCollections(lat: Double, lng: Double, rad: Double, isMineOnly: Bool, isGuest: Bool) async throws -> [Local.NearbyCollectionSummary]
    func fetchComments(_ id: Int) async throws -> [Local.CollectionComment]
    func createComments(id: Int, _ content: String) async throws
    func deleteComment(collectionId: Int, commentId: Int) async throws
    func toggleLike(_ id: Int) async throws -> Bool
    
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
        return try await repository.fetchCollectionSummaries()
    }
    
    func fetchCollectionDetail(id: Int) async throws -> Local.CollectionDetail {
        return try await repository.fetchCollectionDetail(for: id)
    }
    
    func createCollection(_ draft: Local.CollectionDraft) async throws {
        guard let image = draft.image,
              let jpegData = image.resizedAndCompressed()
        else {
            throw CollectionInteractorError.invalidImageData
        }
        
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
    
    func fetchNearbyCollections(lat: Double, lng: Double, rad: Double, isMineOnly: Bool, isGuest: Bool) async throws -> [Local.NearbyCollectionSummary] {
        let request = Local.NearbyRequest(
            latitude: lat,
            longtitude: lng,
            radius: rad,
            isMineOnly: isMineOnly,
            isGuest: isGuest
        )
        return try await repository.fetchNearbyCollections(request)
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
    
    func fetchBirdSuggestions(_ id: Int) async throws -> [Local.BirdSuggestion] {
        return try await repository.fetchBirdSuggestions(collectionId: id)
    }
    
    func suggestBird(_ id: Int, birdId: Int) async throws -> Local.BirdSuggestion {
        try await repository.suggestBird(collectionId: id, birdId: birdId)
        
        return Local.BirdSuggestion(
            bird: .mockData[0],
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
    
    func fetchNearbyCollections(lat: Double, lng: Double, rad: Double, isMineOnly: Bool, isGuest: Bool) async throws -> [Local.NearbyCollectionSummary] { [] }
    
    func editCollection(_ draft: Local.CollectionDraft) async throws { }
    
    func deleteCollection(_ id: Int) async throws { }
    
    func createCollection(_ draft: Local.CollectionDraft) async throws { }
    
    func fetchMyCollections() async throws -> [Local.CollectionSummary] {
        return Local.CollectionSummary.mockData
    }
    
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


import UIKit

extension UIImage {
    func resizedAndCompressed(
        maxLength: CGFloat = 2048,
        quality: CGFloat = 0.8
    ) -> Data? {
        let maxSide = max(size.width, size.height)
        
        guard maxSide > maxLength else {
            // 사이즈가 이미 충분히 작으면 압축만
            return jpegData(compressionQuality: quality)
        }

        let scale = maxLength / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return resized.jpegData(compressionQuality: quality)
    }
}
