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
        guard let container = try? appModelContainer(inMemoryOnly: true) else {
            fatalError("프리뷰용 ModelContainer 생성 실패 — Schema 확인 필요")
        }
        return container
    }
}

@ModelActor
final actor MainRepository: ModelActor {
    let networkService =  SRNetworkServiceImpl()
}
