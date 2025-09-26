//
//  DynamicSheet.swift
//  saerok
//
//  Created by HanSeung on 9/15/25.
//


import SwiftUI

struct DynamicSheet<Content: View>: View {
    var animation: Animation
    @ViewBuilder var content: Content
    @State private var sheetHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            content
                .onGeometryChange(for: CGSize.self) {
                    $0.size
                } action: { newValue in
                    if sheetHeight == .zero {
                        sheetHeight = newValue.height
                    } else {
                        withAnimation(animation) {
                            sheetHeight = newValue.height
                        }
                    }
                }
        }
        .presentationDetents(sheetHeight == .zero ? [.medium] : [.height(sheetHeight)])
    }
}
