//
//  FieldGuideInteractor.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


protocol FieldGuideInteractor {
    func refreshFieldGuide() async throws
    func loadBirdDetails(birdName: String) async throws -> Local.Bird
}

enum FieldGuideInteractorError: Error {
    case networkError(NetworkError)
    case repositoryError(Error)
    case birdNotFound
    case unknownError(Error)
}

struct FieldGuideInteractorImpl: FieldGuideInteractor {
    let networkService: SRNetworkService
    let repository: BirdsRepository

    func refreshFieldGuide() async throws {
        do {
            guard try await repository.isBirdListEmpty() else {
                return
            }
            
            let birdDTOs = try await networkService.fetchBirdList(endpoint: .fullSync)
            try await repository.store(birdDTOs)
            await repository.storeMockData()
            
        } catch let error as NetworkError {
            throw FieldGuideInteractorError.networkError(error)
        } catch let error as BirdsRepositoryError {
            throw FieldGuideInteractorError.repositoryError(error)
        } catch {
            throw FieldGuideInteractorError.unknownError(error)
        }
    }

    @MainActor
    func loadBirdDetails(birdName: String) throws -> Local.Bird {
        return try repository.birdDetail(for: birdName)!
    }
}

struct MockFieldGuideInteractorImpl: FieldGuideInteractor {
//    let repository: BirdsRepository

    func refreshFieldGuide() async throws {
//        await repository.storeMockData()
    }
    
    func loadBirdDetails(birdName: String) throws -> Local.Bird {
        return Local.Bird.mockData[0]
    }
}

