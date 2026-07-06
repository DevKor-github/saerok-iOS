//
//  SRDivider.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

import SwiftUI

/// 1px 구분선 
struct SRDivider: View {
    var color: Color = .srLightGray
    var height: CGFloat = 1

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
    }
}
