//
//  RecentSearch.swift
//  saerok
//
//  Created by HanSeung on 4/22/25.
//


import Foundation
import SwiftData

extension Local {
    @Model
    final class RecentSearchEntity {
        @Relationship var bird: Local.Bird
        var createdAt: Date
        
        init(bird: Local.Bird, createdAt: Date = .now) {
            self.bird = bird
            self.createdAt = createdAt
        }
    }
}
