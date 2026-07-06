//
//  SRCountLabel.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 아이콘 + 카운트 라벨 — 댓글 수 표시 등.
struct SRCountLabel: View {
    var icon: Image.SRIconSet = .commentFilled
    let count: Int

    var body: some View {
        HStack(spacing: 3) {
            icon
                .frame(.default, tintColor: .srLightGray)
            Text("\(count)")
                .font(.SRFontSet.caption1_2)
                .foregroundStyle(.srGray)
        }
    }
}
