//
//  SRTagBadge.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 소형 태그 배지 — "글쓴이", "공지사항", "새록 운영팀" 등.
struct SRTagBadge: View {
    let text: String
    var background: Color = .splash

    var body: some View {
        Text(text)
            .font(.SRFontSet.caption3_2)
            .padding(.horizontal, 3)
            .padding(.vertical, 1)
            .foregroundStyle(.srWhite)
            .background(background)
            .cornerRadius(5)
    }
}
