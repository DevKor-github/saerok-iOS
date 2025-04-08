//
//  FieldGuide.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//

import Foundation
import SwiftData

@Model
final class FieldGuide {
    var title: String             // 도감 제목
    var birds: [Bird]             // 포함된 새들
    var updatedAt: Date           // 생성 일시
    
    init(
        title: String,
        birds: [Bird] = [],
        updatedAt: Date = .now
    ) {
        self.title = title
        self.birds = birds
        self.updatedAt = updatedAt
    }
}
