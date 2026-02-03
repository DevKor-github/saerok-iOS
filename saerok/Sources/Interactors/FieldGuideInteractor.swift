//
//  FieldGuideInteractor.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Foundation

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
        let isEmpty = try repository.checkIsBirdsEmpty()
        let since = readLastSyncDate()
        
        guard try await needsFullSync(isEmpty: isEmpty, since: since) else { return }
        
        do {
            try await repository.fetchAndStoreBirds()
            writeLastSyncDate()
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

private extension FieldGuideInteractorImpl {
    static let lastSyncKey = "LastBirdsSyncDate2.0.2"
    
    func readLastSyncDate() -> Date {
        (UserDefaults.standard.object(forKey: Self.lastSyncKey) as? Date) ?? .distantPast
    }
    
    func writeLastSyncDate(_ date: Date = Date()) {
        UserDefaults.standard.set(date, forKey: Self.lastSyncKey)
    }
    
    func needsFullSync(isEmpty: Bool, since: Date) async throws -> Bool {
        let isUpToDate = try await repository.checkUpToDate(since)
        return isEmpty || !isUpToDate
    }
}

struct MockFieldGuideInteractorImpl: FieldGuideInteractor {
    func refreshBookmarks() async throws { }
    
    func refreshFieldGuide() async throws { }
    
    func loadBirdDetails(birdID: Int) throws -> Local.Bird { throw FieldGuideInteractorError.birdNotFound }
    
    func toggleBookmark(birdID: Int) async throws -> Bool { true }
}
