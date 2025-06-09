//
//  BirdsRepository.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Foundation
import SwiftData

protocol BirdsRepository {
    @MainActor
    func isBirdListEmpty() async throws -> Bool
    @MainActor
    func birdDetail(for id: Int) throws -> Local.Bird?
    
    func fetchAndStoreBirds() async throws
    func syncBookmarks() async throws
    func toggleBookmark(for id: Int) async throws -> Bool
    func storeMockData() async
}

enum BirdsRepositoryError: Error {
    case birdNotFound
    case failedToSaveBirds
    case invalidBirdDTO
}

extension MainRepository: BirdsRepository {
    
    @MainActor
    func isBirdListEmpty() async throws -> Bool {
        let fetchDescriptor = FetchDescriptor<Local.Bird>()
        let result = try modelContainer.mainContext.fetch(fetchDescriptor)
        return result.isEmpty
    }
    
    @MainActor
    func birdDetail(for id: Int) throws -> Local.Bird? {
        let fetchDescriptor = FetchDescriptor(predicate: #Predicate<Local.Bird> {
            $0.id == id
        })
        return try modelContainer.mainContext.fetch(fetchDescriptor).first
    }
    
    func fetchAndStoreBirds() async throws {
        let birdDTOs: DTO.BirdsResponse = try await networkService.performSRRequest(.fullSync)
        try await store(birdDTOs.birds)
    }
    
    func syncBookmarks() async throws {
        let bookmarks: [DTO.MyBookmarkResponse] = try await networkService.performSRRequest(.myBookmarks)
        let bookmarkedIds = Set(bookmarks.map { $0.birdId })
        
        for id in bookmarkedIds {
            let fetchDescriptor = FetchDescriptor<Local.Bird>(predicate: #Predicate {
                $0.id == id
            })
            if let bird = try modelContext.fetch(fetchDescriptor).first {
                bird.isBookmarked = true
            }
        }
        
        let notBookmarkedDescriptor = FetchDescriptor<Local.Bird>(predicate: #Predicate {
            !bookmarkedIds.contains($0.id)
        })
        let unbookmarkedBirds = try modelContext.fetch(notBookmarkedDescriptor)
        for bird in unbookmarkedBirds {
            bird.isBookmarked = false
        }

        try? save()
    }
    
    func toggleBookmark(for id: Int) async throws -> Bool {
        let result: DTO.ToggleBookmarkResponse = try await networkService.performSRRequest(.toggleBookmark(birdId: id))
        return result.bookmarked
    }
    
    func store(_ birds: [DTO.Bird]) async throws {
        try modelContext.transaction {
            try clearExistingBirds()
            let localBirds = convert(dtoBirds: birds)
            if localBirds.isEmpty {
                throw BirdsRepositoryError.invalidBirdDTO
            }
            insertBirds(localBirds)
            storeMockData()
        }
        try? save()
    }
    
    func storeMockData() {
        Local.Bird.mockData.forEach {
            modelContext.insert($0)
        }
    }
}

// MARK: - Helper Method

private extension MainRepository {
    func clearExistingBirds() throws {
        let existingBirds = try modelContext.fetch(FetchDescriptor<Local.Bird>())
        existingBirds.forEach { modelContext.delete($0) }
    }
    
    func convert(dtoBirds: [DTO.Bird]) -> [Local.Bird] {
        dtoBirds.compactMap { Local.Bird.from(dto: $0) }
    }
    
    func insertBirds(_ birds: [Local.Bird]) {
        birds.forEach { modelContext.insert($0) }
    }
    
    func save() throws {
        do {
            try modelContext.save()
        } catch {
            throw BirdsRepositoryError.failedToSaveBirds
        }
    }
}
