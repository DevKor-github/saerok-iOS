//
//  Schema.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import SwiftData

extension Schema {
    static var appSchema: Schema {
        Schema([
            Local.Bird.self,
            Local.FieldGuide.self,
            Local.RecentSearchEntity.self,
        ])
    }
}
