//
//  OffsetReaderView.swift
//  saerok
//
//  Created by HanSeung on 5/15/25.
//


import SwiftUI

struct ScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct OffsetReaderView: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .global).minY)
        }
        .frame(height: 0)
    }
}
