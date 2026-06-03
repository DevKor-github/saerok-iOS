//
//  SREndpoint+Birds.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

// MARK: - Birds API

extension SREndpoint {
    static var fullSync: SREndpoint {
        SREndpoint(path: "birds/full-sync", response: DTO.BirdsResponse.self)
    }

    static func birdChanges(since: Date) -> SREndpoint {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
        return SREndpoint(
            path: "birds/changes",
            query: ["since": formatter.string(from: since)]
        )
    }
}
