//
//  FieldGuideInteractor.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import SwiftData

protocol FieldGuideInteractor {
    func refreshFieldGuide() async throws
    func loadBirdDetails(birdName: String) async throws -> Local.Bird
}

struct FieldGuideInteractorImpl: FieldGuideInteractor {
    let repository: BirdsRepository

    func refreshFieldGuide() async throws {
        try await repository.store(Local.Bird.mockData)
    }

    @MainActor
    func loadBirdDetails(birdName: String) throws -> Local.Bird {
        return try repository.birdDetail(for: birdName)!
    }
}

struct MockFieldGuideInteractorImpl: FieldGuideInteractor {
    func refreshFieldGuide() async throws {}
    
    func loadBirdDetails(birdName: String) throws -> Local.Bird {
        return Local.Bird.mockData[0]
    }
}
