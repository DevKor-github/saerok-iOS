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
    func createCollection(_ request: DTO.CreateCollectionRequest) async throws -> DTO.CreateCollectionResponse
    func getPresignedURL(collectionId: Int, contentType: String) async throws -> DTO.PresignedURLResponse
    func registerImageMetadata(collectionId: Int, request: DTO.RegisterImageRequest) async throws -> DTO.RegisterImageResponse
    func deleteCollection(_ id: Int) async throws
    func editCollection(id: Int, isBirdUpdated: Bool, _ draft: Local.CollectionDraft) async throws
    func fetchNearbyCollections(_ request: Local.NearbyRequest) async throws -> [Local.NearbyCollectionSummary] 
}


extension MainRepository: CollectionRepository {
    func fetchCollectionSummaries() async throws -> [Local.CollectionSummary] {
        let collectionSummaryDTOs: DTO.MyCollectionsResponse = try await networkService.performSRRequest(.myCollections)
        return collectionSummaryDTOs.items.compactMap { Local.CollectionSummary.from(dto: $0) }
    }
    
    func fetchCollectionDetail(for id: Int) async throws -> Local.CollectionDetail {
        let collectionDetailDTO: DTO.CollectionDetailResponse = try await networkService.performSRRequest(.collectionDetail(collectionId: id))
        return Local.CollectionDetail.from(dto: collectionDetailDTO)
    }
    
    func createCollection(_ request: DTO.CreateCollectionRequest) async throws -> DTO.CreateCollectionResponse {
        return try await networkService.performSRRequest(.createCollection(body: request))
    }
    
    func getPresignedURL(collectionId: Int, contentType: String) async throws -> DTO.PresignedURLResponse {
        try await networkService.performSRRequest(.getPresignedURL(collectionId: collectionId, contentType: contentType))
    }
    
    func registerImageMetadata(collectionId: Int, request: DTO.RegisterImageRequest) async throws -> DTO.RegisterImageResponse {
        try await networkService.performSRRequest(.registerUploadedImage(collectionId: collectionId, body: request))
    }
    
    func deleteCollection(_ id: Int) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(.deleteCollection(collectionId: id))
    }
    
    func editCollection(id: Int, isBirdUpdated: Bool, _ draft: Local.CollectionDraft) async throws {
        let dto = draft.toEditDTO(isBirdUpdated: isBirdUpdated)
        let _: DTO.CollectionEditResponse = try await networkService.performSRRequest(.editCollection(
            collectionId: id,
            body: dto
        ))
    }
    
    func fetchNearbyCollections(_ request: Local.NearbyRequest) async throws -> [Local.NearbyCollectionSummary] {
        let dtos: DTO.NearbyCollectionsResponse = try await networkService.performSRRequest(.nearbyCollections(
            lat: request.latitude,
            lng: request.longtitude,
            radius: request.radius,
            isMineOnly: request.isMineOnly,
            isGuest: request.isGuest
        ))
        return dtos.items.map { Local.NearbyCollectionSummary.from(dto: $0) }
    }
}
