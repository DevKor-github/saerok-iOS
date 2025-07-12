//
//  FieldGuideInteractor.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


protocol FieldGuideInteractor {
    func refreshFieldGuide() async throws
    func refreshBookmarks() async throws
    func loadBirdDetails(birdID: Int) async throws -> Local.Bird
    func toggleBookmark(birdID: Int) async throws -> Bool
}

enum FieldGuideInteractorError: Error {
    case networkError(NetworkError)
    case repositoryError(Error)
    case birdNotFound
    case unknownError(Error)
}

struct FieldGuideInteractorImpl: FieldGuideInteractor {
    let repository: BirdsRepository

    func refreshFieldGuide() async throws {
        do {
            try await repository.fetchAndStoreBirds()
        } catch let error as BirdsRepositoryError {
            throw FieldGuideInteractorError.repositoryError(error)
        } catch {
            throw FieldGuideInteractorError.unknownError(error)
        }
    }
    
    func refreshBookmarks() async throws {
        try await repository.syncBookmarks()
    }

    @MainActor
    func loadBirdDetails(birdID: Int) throws -> Local.Bird {
        guard let bird = try repository.birdDetail(for: birdID) else {
            throw FieldGuideInteractorError.birdNotFound
        }
        return bird
    }
    
    func toggleBookmark(birdID: Int) async throws -> Bool {
        return try await repository.toggleBookmark(for: birdID)
    }
}

struct MockFieldGuideInteractorImpl: FieldGuideInteractor {
    func refreshBookmarks() async throws {
        
    }
    
//    let repository: BirdsRepository

    func refreshFieldGuide() async throws {
//        await repository.storeMockData()
    }
    
    func loadBirdDetails(birdID: Int) throws -> Local.Bird {
        return Local.Bird.mockData[0]
    }
    
    func toggleBookmark(birdID: Int) async throws -> Bool {
        true
    }
}

