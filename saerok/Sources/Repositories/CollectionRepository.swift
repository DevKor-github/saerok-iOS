//
//  CollectionRepository.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//


import SwiftData
import Foundation

protocol CollectionRepository {
    func collectionBird(for bird: Local.Bird) async throws -> Local.CollectionBird?
    func store(_ birds: [Local.CollectionBird]) async throws
}


extension MainRepository: CollectionRepository {
    func collectionBird(for bird: Local.Bird) throws -> Local.CollectionBird? {
        let predicate: Predicate<Local.CollectionBird> = #Predicate { $0.isIdentified }
        let fetchDescriptor: FetchDescriptor<Local.CollectionBird> = .init(predicate: predicate)
        return try modelContext.fetch(fetchDescriptor).first
    }
    
    func store(_ birds: [Local.CollectionBird]) async throws {
        try modelContext.transaction {
            birds
                .forEach {
                    modelContext.insert($0)
                }
        }
    }
}
