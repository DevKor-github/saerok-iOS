//
//  CollectionInteractor.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//


protocol CollectionInteractor {
    func refreshCollection() async throws
    func loadCollectionBird(birdID: Int) async throws -> Local.CollectionBird?
}

struct CollectionInteractorImpl: CollectionInteractor {
    let repository: CollectionRepository

    func refreshCollection() async throws {
        try await repository.store(Local.CollectionBird.mockData)
    }

    @MainActor
    func loadCollectionBird(birdID: Int) async throws -> Local.CollectionBird? {
//        return try await repository.collectionBird(for: birdI)
        return nil
    }
}

struct MockCollectionInteractorImpl: CollectionInteractor {
//    let repository: CollectionRepository

    func refreshCollection() async throws {
//        try await repository.store(Local.CollectionBird.mockData)
    }
    
    func loadCollectionBird(birdID: Int) async throws -> Local.CollectionBird? {
        return Local.CollectionBird.mockData[0]
    }
}
