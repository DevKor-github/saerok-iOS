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
    func isBirdListEmpty() throws -> Bool
    @MainActor
    func birdDetail(for name: String) throws -> Local.Bird?
    func store(_ birds: [DTO.Bird]) async throws
    func storeMockData() async
}

enum BirdsRepositoryError: Error {
    case birdNotFound
    case failedToSaveBirds
    case invalidBirdDTO
}

extension MainRepository: BirdsRepository {
    @MainActor
    func isBirdListEmpty() throws -> Bool {
        let fetchDescriptor = FetchDescriptor<Local.Bird>()
        let result = try modelContainer.mainContext.fetch(fetchDescriptor)
        return result.isEmpty
    }
    
    @MainActor
    func birdDetail(for name: String) throws -> Local.Bird? {
        let fetchDescriptor = FetchDescriptor(predicate: #Predicate<Local.Bird> {
            $0.name == name
        })
        
        return try modelContainer.mainContext.fetch(fetchDescriptor).first
    }
    
    func store(_ birds: [DTO.Bird]) async throws {
        try modelContext.transaction {
            let localBirds = birds.compactMap { dto -> Local.Bird? in
                guard let localBird = Local.Bird.from(dto: dto) else {
                    return nil
                }
                return localBird
            }
            
            if localBirds.isEmpty {
                throw BirdsRepositoryError.invalidBirdDTO
            }
            
            localBirds.forEach {
                modelContext.insert($0)
            }
            
            storeMockData()
        }
        
        do {
            try modelContext.save()
        } catch {
            throw BirdsRepositoryError.failedToSaveBirds
        }
    }
    
    func storeMockData() {
        Local.Bird.mockData.forEach {
            modelContext.insert($0)
        }
    }
}
