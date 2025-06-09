//
//  CollectionInteractor.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//

import UIKit


protocol CollectionInteractor {
    func fetchMyCollections() async throws -> [Local.CollectionSummary]
    func fetchCollectionDetail(id: Int) async throws -> Local.CollectionDetail
    func createCollection(_ draft: Local.CollectionDraft) async throws
    func deleteCollection(_ id: Int) async throws
    func editCollection(_ draft: Local.CollectionDraft) async throws
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
              let jpegData = image.jpegData(compressionQuality: 0.8)
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
}

struct MockCollectionInteractorImpl: CollectionInteractor {
    func editCollection(_ draft: Local.CollectionDraft) async throws { }
    
    func deleteCollection(_ id: Int) async throws {
        
    }
    
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
}
