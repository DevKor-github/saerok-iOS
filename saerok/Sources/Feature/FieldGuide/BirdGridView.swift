//
//  BirdGridView.swift
//  saerok
//
//  Created by HanSeung on 5/15/25.
//


import SwiftUI

struct BirdGridView: View {
    let birds: [Local.Bird]
    let onTap: (Local.Bird) -> Void
    let onBookmarkTap: (Local.Bird) async throws -> Void
    @Binding var showPopup: Bool

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 7),
                GridItem(.flexible(), spacing: 7)
            ],
            spacing: 7
        ) {
            ForEach(birds) { bird in
                Button {
                    onTap(bird)
                } label: {
                    BirdCardView(bird: bird, bookmarkTapped: onBookmarkTap, showPopup: $showPopup)
                        .buttonStyle(PressScaleStyle())
                }
            }
            spacer
            
        }
        .padding(.horizontal ,9)
        .background(Color.srLightGray)
    }
    
    private struct PressScaleStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }
    
    private let spacer: some View = {
        Group {
            Rectangle()
            Rectangle()
            Rectangle()
            Rectangle()
        }
        .foregroundStyle(.clear)
        .frame(height: 198)
    }()
}
