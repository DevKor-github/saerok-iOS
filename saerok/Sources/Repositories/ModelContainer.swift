//
//  ModelContainer.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//

import SwiftData

enum Local { }

extension ModelContainer {
    static func appModelContainer(inMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Schema.appSchema
        let modelConfiguration = ModelConfiguration(nil, schema: schema, isStoredInMemoryOnly: inMemoryOnly)
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }

    static var previewable: ModelContainer {
        try! appModelContainer(inMemoryOnly: true)
    }
}

@ModelActor
final actor MainRepository { }
