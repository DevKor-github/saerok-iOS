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
        var birds: [Bird]             // 포함된 새들
        var updatedAt: Date           // 생성 일시
        
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
    static let mockData: Local.FieldGuide = .init(Local.Bird.mockData)
}
