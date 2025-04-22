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
    func birdDetail(for name: String) throws -> Local.Bird?
    func store(_ birds: [Local.Bird]) async throws
}

extension MainRepository: BirdsRepository {
    @MainActor
    func birdDetail(for name: String) throws -> Local.Bird? {
        let fetchDescriptor = FetchDescriptor(predicate: #Predicate<Local.Bird> {
            $0.name == name
        })
        
        return try modelContainer.mainContext.fetch(fetchDescriptor).first
    }
    
    func store(_ birds: [Local.Bird]) async throws {
        try modelContext.transaction {
            birds
                .forEach {
                    modelContext.insert($0)
                }
        }
        
        try modelContext.save()
    }
}
