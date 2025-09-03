//
//  FieldGuide.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Foundation
import SwiftData

extension Local {
    @Model
    final class FieldGuide {
        @Relationship(deleteRule: .cascade) var birds: [Bird]
        var updatedAt: Date               
        
        init(
            _ birds: [Bird] = [],
            updatedAt: Date = .now
        ) {
            self.birds = birds
            self.updatedAt = updatedAt
        }
    }
}

// MARK: - Mock Data

extension Local.FieldGuide {
    @MainActor static let mockData: Local.FieldGuide = .init(Local.Bird.mockData)
}
